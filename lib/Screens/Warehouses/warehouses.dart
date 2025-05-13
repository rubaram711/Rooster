import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/Warehouses/delete_warehouse.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/Warehouses/update_warehouse.dart';
import 'package:rooster_app/Controllers/warehouse_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Controllers/home_controller.dart';

import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';

class WarehousesPage extends StatefulWidget {
  const WarehousesPage({super.key});

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  WarehouseController warehouseController = Get.find();
  String name = '', id = '', number = '', address = '';
  bool isDefaultWarehouseFetched = false;
  // getDefaultWarehouseFromLocalMemory() async {
  //    name=await getDefaultWarehouseNameFromPref();
  //    id=await getDefaultWarehouseIdFromPref();
  //    number=await getDefaultWarehouseNumberFromPref();
  //    address=await getDefaultWarehouseAddressFromPref();
  //    setState(() {
  //      isDefaultWarehouseFetched=true;
  //    });
  //    print('pll');
  //    print(name);
  //    print(id);
  //    print(number);
  //    print('address  $address');
  // }
  final HomeController homeController = Get.find();
  @override
  void initState() {
    // getDefaultWarehouseFromLocalMemory();
    warehouseController.getWarehousesFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          homeController.isMobile.value
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(text: 'warehouses'.tr),
                  gapH10,
                  ReusableButtonWithColor(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 45,
                    onTapFunction: () {
                      homeController.selectedTab.value = 'create_warehouse';
                    },
                    btnText: 'create_warehouse'.tr,
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageTitle(text: 'warehouses'.tr),
                  ReusableButtonWithColor(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: 45,
                    onTapFunction: () {
                      homeController.selectedTab.value = 'create_warehouse';
                    },
                    btnText: 'create_warehouse'.tr,
                  ),
                ],
              ),
          gapH16,
          homeController.isMobile.value
              ? GetBuilder<WarehouseController>(
                builder: (cont) {
                  return SizedBox(
                    // height: MediaQuery.of(context).size.height * 0.6,
                    child: SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        TableTitle(text: 'code'.tr, width: 140),
                                        TableTitle(text: 'name'.tr, width: 140),
                                        TableTitle(
                                          text: 'address'.tr,
                                          width: 140,
                                        ),
                                        TableTitle(
                                          text: 'discontinued'.tr,
                                          width: 100,
                                        ),
                                        TableTitle(
                                          text: 'blocked'.tr,
                                          width: 100,
                                        ),
                                        // TableTitle(
                                        //   text: 'pos'.tr,
                                        //   width: MediaQuery.of(context).size.width * 0.1,
                                        // ),
                                        TableTitle(text: '', width: 50),
                                      ],
                                    ),
                                  ),
                                  cont.isWarehousesFetched
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                          cont.warehousesList.length,
                                          (index) => WarehouseAsRowInTable(
                                            isMobile: true,
                                            warehouseInfo:
                                                cont.warehousesList[index],
                                            index: index,
                                            warehouseListLength:
                                                cont.warehousesList.length,
                                          ),
                                        ),
                                      )
                                      : const CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: homeController.isMobile.value ? 10 : 40,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Primary.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TableTitle(
                          text: 'code'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'name'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'address'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'discontinued'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'blocked'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        // TableTitle(
                        //   text: 'pos'.tr,
                        //   width: MediaQuery.of(context).size.width * 0.1,
                        // ),
                        TableTitle(
                          text: '',
                          width: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ],
                    ),
                  ),
                  GetBuilder<WarehouseController>(
                    builder: (cont) {
                      return cont.isWarehousesFetched
                          ? Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ListView.builder(
                              itemCount:
                                  cont
                                      .warehousesList
                                      .length, //products is data from back res
                              itemBuilder:
                                  (context, index) => WarehouseAsRowInTable(
                                    warehouseInfo: cont.warehousesList[index],
                                    index: index,
                                    warehouseListLength:
                                        cont.warehousesList.length,
                                  ),
                            ),
                          )
                          : loading();
                    },
                  ),
                ],
              ),
          // InkWell(
          //   onTap: (){},
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.add_circle_rounded,
          //         color: Primary.primary,
          //       ),
          //       gapW6,
          //       Text('new_stock_warehouses'.tr,
          //           style: TextStyle(
          //             color: TypographyColor.textTable,
          //           ))
          //     ],
          //   ),
          // ),
          // gapH16,
          // DialogTextField(
          //   textEditingController: addressController,
          //   text: 'address'.tr,
          //   rowWidth:  MediaQuery.of(context).size.width * 0.3,
          //   textFieldWidth:  MediaQuery.of(context).size.width * 0.15,
          //   validationFunc: (){},
          //    ),
          // gapH16,
          // DialogTextField(
          //   textEditingController: comController,
          //   text: 'compensation_warehouse'.tr,
          //   rowWidth:  MediaQuery.of(context).size.width * 0.3,
          //   textFieldWidth:  MediaQuery.of(context).size.width * 0.15,
          //   validationFunc: (){},
          //   ),
        ],
      ),
    );
  }
}

class WarehouseAsRowInTable extends StatefulWidget {
  const WarehouseAsRowInTable({
    super.key,
    required this.warehouseInfo,
    required this.index,
    required this.warehouseListLength,   this.isMobile=false,
  });
  final Map warehouseInfo;
  final int index;
  final int warehouseListLength;
  final bool isMobile;
  @override
  State<WarehouseAsRowInTable> createState() => _WarehouseAsRowInTableState();
}

class _WarehouseAsRowInTableState extends State<WarehouseAsRowInTable> {
  bool isDiscontinued = false, isBlocked = false, isMain = false;
  WarehouseController warehouseController = Get.find();
  HomeController homeController = Get.find();
  @override
  void initState() {
    isDiscontinued = '${widget.warehouseInfo['active']}' == '0';
    isBlocked = widget.warehouseInfo['blocked'] == 1;
    // isMain=widget.warehouseInfo['isMain']==1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: () {
        showDialog<String>(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                elevation: 0,
                content: UpdateWareHouseDialog(index: widget.index),
              ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: homeController.isMobile.value ? 10 : 40,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TableItem(
              text: '${widget.warehouseInfo['warehouseNumber'] ?? ''}',
              width:widget.isMobile?140: MediaQuery.of(context).size.width * 0.1,
            ),
            TableItem(
              text: '${widget.warehouseInfo['name'] ?? ''}',
              width:widget.isMobile?140: MediaQuery.of(context).size.width * 0.1,
            ),
            TableItem(
              text: '${widget.warehouseInfo['address'] ?? ''}',
              width:widget.isMobile?140: MediaQuery.of(context).size.width * 0.1,
            ),
            SizedBox(
              width: widget.isMobile?100:MediaQuery.of(context).size.width * 0.1,
              child: Checkbox(
                // checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: isDiscontinued,
                onChanged: (bool? value) async {
                  setState(() {
                    isDiscontinued = value!;
                  });
                  var p = await updateWarehouse(
                    '${warehouseController.warehousesList[widget.index]['id']}',
                    '${widget.warehouseInfo['name'] ?? ''}',
                    '${widget.warehouseInfo['address'] ?? ''}',
                    isDiscontinued ? '1' : '0',
                    isMain ? '1' : '0',
                    isBlocked ? '1' : '0',
                  );
                  if (p['success'] == true) {
                    // warehouseController.resetValues();
                    warehouseController.getWarehousesFromBack();
                    CommonWidgets.snackBar('success'.tr, p['message']);
                  } else {
                    CommonWidgets.snackBar('error', p['message']);
                    setState(() {
                      isDiscontinued = !isDiscontinued;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width:widget.isMobile?100: MediaQuery.of(context).size.width * 0.1,
              child: Checkbox(
                // checkColor: Colors.white,
                // fillColor: MaterialStateProperty.resolveWith(getColor),
                value: isBlocked,
                onChanged: (bool? value) async {
                  setState(() {
                    isBlocked = value!;
                  });
                  var p = await updateWarehouse(
                    '${warehouseController.warehousesList[widget.index]['id']}',
                    '${widget.warehouseInfo['name'] ?? ''}',
                    '${widget.warehouseInfo['address'] ?? ''}',
                    isDiscontinued ? '1' : '0',
                    isMain ? '1' : '0',
                    isBlocked ? '1' : '0',
                  );
                  if (p['success'] == true) {
                    // warehouseController.resetValues();
                    warehouseController.getWarehousesFromBack();
                    CommonWidgets.snackBar('success'.tr, p['message']);
                  } else {
                    CommonWidgets.snackBar('error', p['message']);
                    setState(() {
                      isBlocked = !isBlocked;
                    });
                  }
                },
              ),
            ),
            // SizedBox(
            //     width: MediaQuery.of(context).size.width * 0.1,
            //     child:Checkbox(
            //       // checkColor: Colors.white,
            //       // fillColor: MaterialStateProperty.resolveWith(getColor),
            //       value: isMain,
            //       onChanged: (bool? value) async {
            //         setState(() {
            //           isMain = value!;
            //         });
            //         var p = await updateWarehouse(
            //           '${warehouseController.warehousesList[widget.index]['id']}',
            //           '${widget.warehouseInfo['name'] ?? ''}',
            //           '${widget.warehouseInfo['address'] ?? ''}',
            //           isDiscontinued ? '1' : '0',
            //           isMain ? '1' : '0',
            //           isBlocked ? '1' : '0',
            //         );
            //         if (p['success'] == true) {
            //           // warehouseController.resetValues();
            //           warehouseController.getWarehousesFromBack();
            //           CommonWidgets.snackBar('success'.tr, p['message']);
            //         } else {
            //           CommonWidgets.snackBar('error', p['message']);
            //           setState(() {
            //             isMain = !isMain;
            //           });
            //         }
            //       },
            //     )
            // ),
            SizedBox(
              width: widget.isMobile?50:MediaQuery.of(context).size.width * 0.05,
              child: InkWell(
                onTap: () async {
                  var res = await deleteWarehouse(
                    '${widget.warehouseInfo['id']}',
                  );
                  var p = json.decode(res.body);
                  if (res.statusCode == 200) {
                    CommonWidgets.snackBar('Success', p['message']);
                    // warehouseController.resetValues();
                    warehouseController.getWarehousesFromBack();
                  } else {
                    CommonWidgets.snackBar('error', p['message']);
                  }
                },
                child: Icon(Icons.delete_outline, color: Primary.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateWareHouseDialog extends StatefulWidget {
  const UpdateWareHouseDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdateWareHouseDialog> createState() => _UpdateWareHouseDialogState();
}

class _UpdateWareHouseDialogState extends State<UpdateWareHouseDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isDiscontinued = false;
  bool isBlocked = false;
  bool isMain = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  WarehouseController warehouseController = Get.find();
  HomeController homeController = Get.find();
  @override
  void initState() {
    nameController.text =
        '${warehouseController.warehousesList[widget.index]['name'] ?? ''}';
    addressController.text =
        '${warehouseController.warehousesList[widget.index]['address'] ?? ''}';
    isDiscontinued =
        '${warehouseController.warehousesList[widget.index]['active']}' == '0';
    isBlocked =
        '${warehouseController.warehousesList[widget.index]['blocked']}' == '1';
    // isMain = '${warehouseController.warehousesList[widget.index]['isMain']}' == '1';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // width: Sizes.deviceWidth*0.2,
      height: 500,
      // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            gapH20,
            DialogTextField(
              textEditingController: nameController,
              text: '${'title'.tr}*',
              rowWidth:
                  homeController.isMobile.value
                      ? MediaQuery.of(context).size.width * 0.65
                      : MediaQuery.of(context).size.width * 0.3,
              textFieldWidth:
                  homeController.isMobile.value
                      ? MediaQuery.of(context).size.width * 0.4
                      : MediaQuery.of(context).size.width * 0.25,
              validationFunc: (String value) {
                if (value.isEmpty) {
                  return 'required_field'.tr;
                }
                return null;
              },
            ),
            gapH16,
            DialogTextField(
              textEditingController: addressController,
              text: 'address'.tr,
              rowWidth:
                  homeController.isMobile.value
                      ? MediaQuery.of(context).size.width * 0.65
                      : MediaQuery.of(context).size.width * 0.3,
              textFieldWidth:
                  homeController.isMobile.value
                      ? MediaQuery.of(context).size.width * 0.4
                      : MediaQuery.of(context).size.width * 0.25,
              validationFunc: (String value) {},
            ),
            gapH16,
            Row(
              children: [
                Text('discontinued'.tr),
                gapW28,
                Checkbox(
                  value: isDiscontinued,
                  onChanged: (bool? value) {
                    setState(() {
                      isDiscontinued = value!;
                    });
                  },
                ),
              ],
            ),
            gapH16,
            Row(
              children: [
                Text('blocked'.tr),
                gapW28,
                Checkbox(
                  value: isBlocked,
                  onChanged: (bool? value) {
                    setState(() {
                      isBlocked = value!;
                    });
                  },
                ),
              ],
            ),
            gapH16,
            // Row(
            //   children: [
            //     Text('main'.tr),
            //     gapW28,
            //     Checkbox(
            //       value: isMain,
            //       onChanged: (bool? value) {
            //         setState(() {
            //           isMain = value!;
            //         });
            //       },
            //     ),
            //   ],
            // ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      nameController.text =
                          '${warehouseController.warehousesList[widget.index]['name'] ?? ''}';
                      addressController.text =
                          '${warehouseController.warehousesList[widget.index]['address'] ?? ''}';
                      isDiscontinued =
                          '${warehouseController.warehousesList[widget.index]['active']}' ==
                          '0';
                      isBlocked =
                          '${warehouseController.warehousesList[widget.index]['blocked']}' ==
                          '1';
                      // isMain = '${warehouseController.warehousesList[widget.index]['isMain']}' == '1';
                    });
                  },
                  child: Text(
                    'discard'.tr,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Primary.primary,
                    ),
                  ),
                ),
                gapW24,
                ReusableButtonWithColor(
                  btnText: 'save'.tr,
                  onTapFunction: () async {
                    if (_formKey.currentState!.validate()) {
                      var p = await updateWarehouse(
                        '${warehouseController.warehousesList[widget.index]['id']}',
                        nameController.text,
                        addressController.text,
                        isDiscontinued ? '1' : '0',
                        isMain ? '1' : '0',
                        isBlocked ? '1' : '0',
                      );
                      if (p['success'] == true) {
                        Get.back();
                        // warehouseController.resetValues();
                        warehouseController.resetWarehouse();
                        warehouseController.getWarehousesFromBack();
                        nameController.clear();
                        addressController.clear();
                        CommonWidgets.snackBar('success'.tr, p['message']);
                      } else {
                        CommonWidgets.snackBar('error', p['message']);
                      }
                    }
                  },
                  width: 100,
                  height: 35,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
