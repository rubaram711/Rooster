import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/Warehouses/delete_warehouse.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/Warehouses/update_warehouse.dart';
import 'package:rooster_app/Controllers/warehouse_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/ConfigurationsBackend/Warehouses/create_warehouse.dart';
import '../../Controllers/home_controller.dart';

import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';


List tabsList = [
  'warehouses',
  'create_warehouse',
];

List tabsContent = [
  const GeneralTabInWarehouses(),
  const CreateWarehouse()
];

class WarehousesDialogContent extends StatefulWidget {
  const WarehousesDialogContent({super.key});

  @override
  State<WarehousesDialogContent> createState() =>
      _WarehousesDialogContentState();
}

class _WarehousesDialogContentState
    extends State<WarehousesDialogContent> {
  final WarehouseController warehouseController = Get.find();
  final HomeController homeController = Get.find();
  @override
  void initState() {
    warehouseController.selectedTabIndex=0;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<WarehouseController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.05),
          // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(text: 'stock_warehouses'.tr),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: CircleAvatar(
                      backgroundColor: Primary.primary,
                      radius: 15,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
              gapH24,
              Wrap(
                  spacing: 0.0,
                  direction: Axis.horizontal,
                  children: tabsList
                      .map((element) => _buildTabChipItem(
                      element,
                      tabsList.indexOf(element)))
                      .toList()),
              tabsContent[cont.selectedTabIndex],
              const Spacer(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     TextButton(
              //         onPressed: (){
              //           setState(() {
              //             addressController.clear();
              //             comController.clear();
              //           });
              //         },
              //         child: Text('discard'.tr,style: TextStyle(
              //             decoration: TextDecoration.underline,
              //             color: Primary.primary
              //         ),)),
              //     gapW24,
              //     ReusableButtonWithColor(btnText: 'save'.tr, onTapFunction: (){}, width: 100, height: 35),
              //   ],
              // )
            ],
          ),
        );
      }
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<WarehouseController>(
      builder: (cont) {
        return GestureDetector(
          onTap: () {
              cont.setSelectedTabIndex (index);
          },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(9),
                        topRight: Radius.circular(9)))),
            child: Container(
              width: homeController.isMobile.value? name.length*10:name.length*15,// MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.height * 0.07,
              // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              decoration: BoxDecoration(
                  color: cont.selectedTabIndex == index ? Primary.p20 : Colors.white,
                  border: cont.selectedTabIndex == index
                      ? Border(
                    top: BorderSide(color: Primary.primary, width: 3),
                  )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                      spreadRadius: 9,
                      blurRadius: 9,
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: Center(
                child: Text(
                  name.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Primary.primary),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}


// TextEditingController addressController = TextEditingController();
// TextEditingController comController = TextEditingController();

class GeneralTabInWarehouses extends StatefulWidget {
  const GeneralTabInWarehouses({super.key});

  @override
  State<GeneralTabInWarehouses> createState() => _GeneralTabInWarehousesState();
}

class _GeneralTabInWarehousesState extends State<GeneralTabInWarehouses> {
  WarehouseController warehouseController=Get.find();
  String name='',id='',number='',address='';
  bool isDefaultWarehouseFetched=false;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:   EdgeInsets.symmetric(horizontal:  homeController.isMobile.value? 10:40, vertical: 15),
          decoration: BoxDecoration(
              color: Primary.primary,
              borderRadius: const BorderRadius.all(Radius.circular(6))),
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
        // isDefaultWarehouseFetched? Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        //   decoration: const BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.all(Radius.circular(0))),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       TableItem(
        //         text: number,
        //         width: MediaQuery.of(context).size.width * 0.1,
        //       ),
        //       TableItem(
        //         text: name,
        //         width: MediaQuery.of(context).size.width * 0.1,
        //       ),
        //       TableItem(
        //         text: address,
        //         width: MediaQuery.of(context).size.width * 0.1,
        //       ),
        //       SizedBox(
        //           width: MediaQuery.of(context).size.width * 0.1,
        //           child:const Icon(Icons.close,color: Colors.grey,)
        //       ),
        //       SizedBox(
        //           width: MediaQuery.of(context).size.width * 0.1,
        //           child:const Icon(Icons.close,color: Colors.grey,)
        //       ),
        //       SizedBox(
        //         width: MediaQuery.of(context).size.width * 0.05,
        //       ),
        //     ],
        //   ),
        // ):const SizedBox(),
        GetBuilder<WarehouseController>(
          builder: (cont) {
            return cont.isWarehousesFetched?Container(
              color: Colors.white,
              height: homeController.isMobile.value?MediaQuery.of(context).size.height * 0.5:MediaQuery.of(context).size.height * 0.6,
              child: ListView.builder(
                itemCount: cont.warehousesList.length, //products is data from back res
                itemBuilder: (context, index) => WarehouseAsRowInTable(
                 warehouseInfo: cont.warehousesList[index],
                 index: index,
                 warehouseListLength: cont.warehousesList.length,
                ),
              ),
            ):loading();
          }
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
    );
  }


}

class WarehouseAsRowInTable extends StatefulWidget {
  const WarehouseAsRowInTable({super.key, required this.warehouseInfo, required this.index, required this.warehouseListLength});
  final Map warehouseInfo;
  final int index;
  final int warehouseListLength;
  @override
  State<WarehouseAsRowInTable> createState() => _WarehouseAsRowInTableState();
}

class _WarehouseAsRowInTableState extends State<WarehouseAsRowInTable> {
  bool isDiscontinued=false,isBlocked=false,isMain=false;
  WarehouseController warehouseController = Get.find();
  HomeController homeController = Get.find();
  @override
  void initState() {
    isDiscontinued='${widget.warehouseInfo['active']}'=='0';
    isBlocked=widget.warehouseInfo['blocked']==1;
    // isMain=widget.warehouseInfo['isMain']==1;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onDoubleTap: (){
        showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                    backgroundColor:
                    Colors.white,
                    shape:
                    const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              9)),
                    ),
                    elevation: 0,
                    content: UpdateWareHouseDialog(index:widget.index,)));
      },
      child: Container(
        padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value? 10: 40, vertical: 10),
        decoration: BoxDecoration(
            color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TableItem(
              text: '${widget.warehouseInfo['warehouseNumber'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            TableItem(
              text: '${widget.warehouseInfo['name'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            TableItem(
              text: '${widget.warehouseInfo['address'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child:Checkbox(
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
                )
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child:Checkbox(
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
                )
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
              width: MediaQuery.of(context).size.width * 0.05,
              child: InkWell(
                onTap: () async{
                  var res = await deleteWarehouse(
                      '${widget.warehouseInfo['id']}');
                  var p = json.decode(res.body);
                  if (res.statusCode == 200) {
                    CommonWidgets.snackBar('Success',
                        p['message']);
                    // warehouseController.resetValues();
                    warehouseController.getWarehousesFromBack();
                  } else {
                    CommonWidgets.snackBar(
                        'error',  p['message']);
                  }
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
    );
  }
}



class CreateWarehouse extends StatefulWidget {
  const CreateWarehouse({super.key});

  @override
  State<CreateWarehouse> createState() => _CreateWarehouseState();
}

class _CreateWarehouseState extends State<CreateWarehouse> {
  TextEditingController warehouseNameController = TextEditingController();
  TextEditingController warehouseAddressController = TextEditingController();
  final WarehouseController warehouseController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final HomeController homeController = Get.find();
  bool isDiscontinued=false,isBlocked=false,isMainWarehouse=false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
      height:homeController.isMobile.value? MediaQuery.of(context).size.height * 0.6: MediaQuery.of(context).size.height * 0.65,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PageTitle(text: 'create_warehouse'.tr),
            gapH32,
            DialogTextField(
              textEditingController: warehouseNameController,
              text: '${'warehouse_name'.tr}*',
              rowWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.65:MediaQuery.of(context).size.width * 0.4,
              textFieldWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.4: MediaQuery.of(context).size.width * 0.3,
              validationFunc: (String val) {
                if(val.isEmpty){
                  return 'required_field'.tr;
                }return null;
              },
            ),
            gapH10,
            DialogTextField(
              textEditingController: warehouseAddressController,
              text: 'address'.tr,
              rowWidth: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.65:MediaQuery.of(context).size.width * 0.4,
              textFieldWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.4: MediaQuery.of(context).size.width * 0.3,
              validationFunc: (String val) {},
            ),
            gapH10,
            Row(
              children: [
                Expanded(
                    child: ListTile(
                      title: Text('blocked'.tr,
                          style: const TextStyle(fontSize: 12)),
                      leading: Checkbox(
                        value:isBlocked,
                        onChanged: (bool? value) {
                          setState(() {
                            isBlocked=value!;
                          });
                        },
                      ),
                    )),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        warehouseNameController.clear();
                        warehouseAddressController.clear();
                        isBlocked =false;
                        isDiscontinued=false;
                        isMainWarehouse=false;
                      });
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
                      if (_formKey.currentState!.validate()) {
                        var res = await createWarehouse(
                            warehouseNameController.text,
                            warehouseAddressController.text,
                            '0',//isDiscontinued?'1':'0',
                            isMainWarehouse?'1':'0',
                            isBlocked?'1':'0'
                           );
                        if (res['success'] == true) {
                          CommonWidgets.snackBar('Success',
                              res['message']);
                          warehouseController.setSelectedTabIndex(0);
                          // warehouseController.resetValues();
                          warehouseController.getWarehousesFromBack();
                        } else {
                          CommonWidgets.snackBar(
                              'error', res['message']);
                        }
                      }
                    },
                    width: 100,
                    height: 35),
              ],
            )
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
  State<UpdateWareHouseDialog> createState() =>
      _UpdateWareHouseDialogState();
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
    nameController.text='${warehouseController.warehousesList[widget.index]['name'] ?? ''}';
    addressController.text='${warehouseController.warehousesList[widget.index]['address'] ?? ''}';
    isDiscontinued = '${warehouseController.warehousesList[widget.index]['active']}' == '0';
    isBlocked = '${warehouseController.warehousesList[widget.index]['blocked']}' == '1';
    // isMain = '${warehouseController.warehousesList[widget.index]['isMain']}' == '1';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
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
                rowWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.65: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.4: MediaQuery.of(context).size.width * 0.25,
                validationFunc: (String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }return null;
                },
              ),
              gapH16,
              DialogTextField(
                textEditingController: addressController,
                text: 'address'.tr,
                rowWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.65: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.4:MediaQuery.of(context).size.width * 0.25,
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
                          nameController.text='${warehouseController.warehousesList[widget.index]['name'] ?? ''}';
                          addressController.text='${warehouseController.warehousesList[widget.index]['address'] ?? ''}';
                          isDiscontinued = '${warehouseController.warehousesList[widget.index]['active']}' == '0';
                          isBlocked = '${warehouseController.warehousesList[widget.index]['blocked']}' == '1';
                          // isMain = '${warehouseController.warehousesList[widget.index]['isMain']}' == '1';
                        });
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
                      height: 35),
                ],
              ),
            ],
          ),
        )
    );
  }
}
