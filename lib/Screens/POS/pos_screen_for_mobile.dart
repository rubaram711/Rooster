import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/PosBackend/add_pos.dart';
import '../../Backend/PosBackend/update_pos.dart';
import '../../Controllers/pos_controller.dart';
import '../../Controllers/warehouse_controller.dart';
// import '../../Locale_Memory/DefaultWareHouse/save_default_warehouse_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_chip.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';

class PosScreenForMobile extends StatefulWidget {
  const PosScreenForMobile({super.key});

  @override
  State<PosScreenForMobile> createState() => _PosScreenForMobileState();
}

class _PosScreenForMobileState extends State<PosScreenForMobile> {
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool isClicked = false;
  String selectedPos = '';
  PosController posController = Get.find();
  WarehouseController warehouseController = Get.find();
  final _formKey = GlobalKey<FormState>();

  // getDefaultWarehouseFromLocalMemory() async {
  //   String name=await getDefaultWarehouseNameFromPref();
  //   String id=await getDefaultWarehouseIdFromPref();
  //   // posController.setSelectedWarehouseId(id);
  //   // posController.warehouseControllerForDropMenu.text=name;
  //   posController.setIsDefaultWarehouseFetched(true);
  //
  // }
  @override
  void initState() {
    posController.getPossFromBack();
    posController.getFieldsForCreatePosFromBack();
    warehouseController.getWarehousesFromBack();
    // getDefaultWarehouseFromLocalMemory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      // height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'poss'.tr),
            gapH24,
            ReusableChip(name: 'all_poss'.tr, isDesktop: false),
            _generalTabInPos(),
            // const Spacer(),
            gapH20,
            isClicked
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          addressController.clear();
                          nameController.clear();
                          posController.warehouseControllerForDropMenu
                              .clear(); //todo change to default warehouse
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
                        if (posController.selectedWarehouseId == '') {
                          CommonWidgets.snackBar(
                            'error',
                            'you must choose warehouses first',
                          );
                        } else if (warehouseController.warehouseIdsList
                                .contains(posController.selectedWarehouseId) ==
                            false) {
                          CommonWidgets.snackBar(
                            'error',
                            'you must choose an existing warehouses',
                          );
                        } else if (_formKey.currentState!.validate()) {
                          var p = await addPos(
                            nameController.text,
                            addressController.text,
                            posController.selectedWarehouseId,
                          );
                          if (p['success'] == true) {
                            setState(() {
                              isClicked = false;
                            });
                            posController.getPossFromBack();
                            CommonWidgets.snackBar('', p['message']);
                            nameController.clear();
                            addressController.clear();
                            posController.warehouseControllerForDropMenu
                                .clear(); //todo change to default warehouse
                          } else {
                            CommonWidgets.snackBar('error', p['message']);
                          }
                        }
                      },
                      width: 100,
                      height: 35,
                    ),
                  ],
                )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _generalTabInPos() {
    return GetBuilder<PosController>(
      builder: (posCont) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //     Container(
            //       padding: const EdgeInsets.symmetric(vertical: 15),
            //       decoration: BoxDecoration(
            //           color: Primary.primary,
            //           borderRadius: const BorderRadius.all(Radius.circular(6))),
            //       child:SizedBox(
            // height: MediaQuery.of(context).size.height * 0.4,
            posCont.isPossFetched
                ? SingleChildScrollView(
                  child: Row(
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
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
                                    TableTitle(text: 'code'.tr, width: 150),
                                    TableTitle(text: 'name'.tr, width: 150),
                                    TableTitle(text: 'address'.tr, width: 150),
                                    TableTitle(
                                      text: 'warehouse'.tr,
                                      width: 200,
                                    ),
                                    SizedBox(width: 100),
                                  ],
                                ),
                              ),
                              isClicked
                                  ? posCont.isCodeFetched
                                      ? Container(
                                        height: 62,
                                        decoration: BoxDecoration(
                                          color: Primary.p10,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(0),
                                          ),
                                        ),
                                        child: Form(
                                          key: _formKey,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 3),
                                                width: 150,
                                                child: Center(
                                                  child: Text(posCont.code),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 3),
                                                width: 150,
                                                child: Center(
                                                  child: ReusableTextField(
                                                    textEditingController:
                                                        nameController,
                                                    onChangedFunc: (val) {},
                                                    hint: '',
                                                    validationFunc: (
                                                      String value,
                                                    ) {
                                                      if (value.isEmpty) {
                                                        return 'required_field'
                                                            .tr;
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    isPasswordField: false,
                                                    isEnable: true,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 3),
                                                width: 150,
                                                child: Center(
                                                  child: ReusableTextField(
                                                    textEditingController:
                                                        addressController,
                                                    onChangedFunc: (val) {},
                                                    hint: '',
                                                    validationFunc: (val) {},
                                                    isPasswordField: false,
                                                    isEnable: true,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 3),
                                                width: 200,
                                                // height: 56,
                                                child: GetBuilder<WarehouseController>(
                                                  builder: (cont) {
                                                    return cont
                                                            .isWarehousesFetched
                                                        ? DropdownMenu<String>(
                                                          width: 200,
                                                          // requestFocusOnTap: false,
                                                          enableSearch: true,
                                                          controller:
                                                              posController
                                                                  .warehouseControllerForDropMenu,
                                                          hintText:
                                                              '${'search'.tr}...',
                                                          inputDecorationTheme: InputDecorationTheme(
                                                            // filled: true,
                                                            hintStyle:
                                                                const TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                            contentPadding:
                                                                const EdgeInsets.fromLTRB(
                                                                  20,
                                                                  0,
                                                                  25,
                                                                  5,
                                                                ),
                                                            // outlineBorder: BorderSide(color: Colors.black,),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Primary
                                                                    .primary
                                                                    .withAlpha(
                                                                      (0.2 * 255)
                                                                          .toInt(),
                                                                    ),
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  const BorderRadius.all(
                                                                    Radius.circular(
                                                                      9,
                                                                    ),
                                                                  ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Primary
                                                                    .primary
                                                                    .withAlpha(
                                                                      (0.4 * 255)
                                                                          .toInt(),
                                                                    ),
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  const BorderRadius.all(
                                                                    Radius.circular(
                                                                      9,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                          // menuStyle: ,
                                                          menuHeight: 250,
                                                          dropdownMenuEntries:
                                                              cont.warehousesNameList.map<
                                                                DropdownMenuEntry<
                                                                  String
                                                                >
                                                              >((String option) {
                                                                return DropdownMenuEntry<
                                                                  String
                                                                >(
                                                                  value: option,
                                                                  label: option,
                                                                );
                                                              }).toList(),
                                                          enableFilter: true,
                                                          onSelected: (
                                                            String? val,
                                                          ) {
                                                            var index = cont
                                                                .warehousesNameList
                                                                .indexOf(val!);
                                                            posController
                                                                .setSelectedWarehouseId(
                                                                  '${cont.warehouseIdsList[index]}',
                                                                );
                                                          },
                                                        )
                                                        : loading();
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 100),
                                            ],
                                          ),
                                        ),
                                      )
                                      : loading()
                                  : const SizedBox(),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    posCont.posList.length,
                                    (index) => PosAsRowInTableForMobile(
                                      info: posCont.posList[index],
                                      index: index,
                                      posListLength: posCont.posList.length,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : const Center(child: CircularProgressIndicator()),
            // ),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           TableTitle(
            //             text: 'code'.tr,
            //             width: MediaQuery.of(context).size.width * 0.1,
            //           ),
            //           TableTitle(
            //             text: 'name'.tr,
            //             width: MediaQuery.of(context).size.width * 0.1,
            //           ),
            //           TableTitle(
            //             text: 'address'.tr,
            //             width: MediaQuery.of(context).size.width * 0.1,
            //           ),
            //           TableTitle(
            //             text: 'warehouse'.tr,
            //             width: MediaQuery.of(context).size.width * 0.15,
            //           ),
            //           SizedBox(
            //             width: MediaQuery.of(context).size.width * 0.05,
            //           )
            //         ],
            //       ),
            //     ),
            //     isClicked
            //         ? posCont.isCodeFetched
            //             ? Container(
            //                 height: 55,
            //                 decoration: BoxDecoration(
            //                     color: Primary.p10,
            //                     borderRadius:
            //                         const BorderRadius.all(Radius.circular(0))),
            //                 child: Form(
            //                   key: _formKey,
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                     children: [
            //                       SizedBox(
            //                         width: MediaQuery.of(context).size.width * 0.1,
            //                         child: Center(
            //                           child: Text(posCont.code),
            //                         ),
            //                       ),
            //                       SizedBox(
            //                         width: MediaQuery.of(context).size.width * 0.1,
            //                         child: Center(
            //                           child: ReusableTextField(
            //                             textEditingController: nameController,
            //                             onChangedFunc: (val) {},
            //                             hint: '',
            //                             validationFunc: (String value) {
            //                               if (value.isEmpty) {
            //                                 return 'required_field'.tr;
            //                               } else {
            //                                 return null;
            //                               }
            //                             },
            //                             isPasswordField: false,
            //                             isEnable: true,
            //                           ),
            //                         ),
            //                       ),
            //                       SizedBox(
            //                         width: MediaQuery.of(context).size.width * 0.1,
            //                         child: Center(
            //                           child: ReusableTextField(
            //                             textEditingController: addressController,
            //                             onChangedFunc: (val) {},
            //                             hint: '',
            //                             validationFunc: (val) {},
            //                             isPasswordField: false,
            //                             isEnable: true,
            //                           ),
            //                         ),
            //                       ),
            //                       GetBuilder<WarehouseController>(builder: (cont) {
            //                         return cont.isWarehousesFetched
            //                             ? DropdownMenu<String>(
            //                                 width: MediaQuery.of(context).size.width *
            //                                     0.15,
            //                                 // requestFocusOnTap: false,
            //                                 enableSearch: true,
            //                                 controller: posController
            //                                     .warehouseControllerForDropMenu,
            //                                 hintText: '${'search'.tr}...',
            //                                 inputDecorationTheme:
            //                                     InputDecorationTheme(
            //                                   // filled: true,
            //                                   hintStyle: const TextStyle(
            //                                       fontStyle: FontStyle.italic),
            //                                   contentPadding:
            //                                       const EdgeInsets.fromLTRB(
            //                                           20, 0, 25, 5),
            //                                   // outlineBorder: BorderSide(color: Colors.black,),
            //                                   enabledBorder: OutlineInputBorder(
            //                                     borderSide: BorderSide(
            //                                         color: Primary.primary
            //                                             .withAlpha((0.2 * 255).toInt()),
            //                                         width: 1),
            //                                     borderRadius: const BorderRadius.all(
            //                                         Radius.circular(9)),
            //                                   ),
            //                                   focusedBorder: OutlineInputBorder(
            //                                     borderSide: BorderSide(
            //                                         color: Primary.primary
            //                                             .withAlpha((0.4 * 255).toInt()),
            //                                         width: 2),
            //                                     borderRadius: const BorderRadius.all(
            //                                         Radius.circular(9)),
            //                                   ),
            //                                 ),
            //                                 // menuStyle: ,
            //                                 menuHeight: 250,
            //                                 dropdownMenuEntries: cont
            //                                     .warehousesNameList
            //                                     .map<DropdownMenuEntry<String>>(
            //                                         (String option) {
            //                                   return DropdownMenuEntry<String>(
            //                                     value: option,
            //                                     label: option,
            //                                   );
            //                                 }).toList(),
            //                                 enableFilter: true,
            //                                 onSelected: (String? val) {
            //                                   var index = cont.warehousesNameList
            //                                       .indexOf(val!);
            //                                   posController.setSelectedWarehouseId(
            //                                       '${cont.warehouseIdsList[index]}');
            //                                 },
            //                               )
            //                             : loading();
            //                       }),
            //                       SizedBox(
            //                         width: MediaQuery.of(context).size.width * 0.05,
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               )
            //             : loading()
            //         : const SizedBox(),
            //
            //     posCont.isPossFetched
            //         ? Container(
            //             color: Colors.white,
            //             height: posCont.posList.length * 55,
            //             child: ListView.builder(
            //               itemCount:
            //                   posCont.posList.length, //products is data from back res
            //               itemBuilder: (context, index) => PosAsRowInTable(
            //                 info: posCont.posList[index],
            //                 index: index,
            //                 posListLength: posCont.posList.length,
            //               ),
            //             ),
            //           )
            //         : const Center(
            //             child: CircularProgressIndicator(),
            //           ),
            gapH10,
            isClicked
                ? const SizedBox()
                : ReusableAddCard(
                  text: 'new_pos'.tr,
                  onTap: () {
                    setState(() {
                      isClicked = true;
                    });
                  },
                ),
          ],
        );
      },
    );
  }
}

class PosAsRowInTableForMobile extends StatefulWidget {
  const PosAsRowInTableForMobile({
    super.key,
    required this.info,
    required this.index,
    required this.posListLength,
  });
  final Map info;
  final int index;
  final int posListLength;
  @override
  State<PosAsRowInTableForMobile> createState() => _PosAsRowInTableForMobileState();
}

class _PosAsRowInTableForMobileState extends State<PosAsRowInTableForMobile> {
  bool isDiscontinued = false;
  @override
  void initState() {
    isDiscontinued = '${widget.info['active']}' == '0';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PosController>(
      builder: (cont) {
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
                    content: UpdatePosDialog(index: widget.index),
                  ),
            );
          },
          child: Container(
            height: 55,
            // padding: const EdgeInsets.symmetric(
            //   horizontal: 40,
            // ),
            decoration: BoxDecoration(
              color: (widget.index % 2 != 0) ? Primary.p10 : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TableItem(
                    text: '${widget.info['posCode'] ?? ''}',
                    width: 150,
                  ),
                  TableItem(
                    text: '${widget.info['name'] ?? ''}',
                    width: 150,
                  ),
                  TableItem(
                    text: '${widget.info['address'] ?? ''}',
                    width:150,
                  ),
                  TableItem(
                    text:
                        widget.info['warehouse'] != null
                            ? '${widget.info['warehouse']['name'] ?? ''}'
                            : '',
                    width:200,
                  ),
                  SizedBox(
                    width: 100,
                    child: Checkbox(
                      value: isDiscontinued,
                      onChanged: (bool? value) async {
                        setState(() {
                          isDiscontinued = value!;
                        });
                        // var p = await updateWarehouse(
                        //   '${warehouseController.warehousesList[widget.index]['id']}',
                        //   '${widget.warehouseInfo['name'] ?? ''}',
                        //   '${widget.warehouseInfo['address'] ?? ''}',
                        //   isDiscontinued ? '1' : '0',
                        //   isMain ? '1' : '0',
                        //   isBlocked ? '1' : '0',
                        // );
                        // if (p['success'] == true) {
                        //   // warehouseController.resetValues();
                        //   warehouseController.getWarehousesFromBack();
                        //   CommonWidgets.snackBar('success'.tr, p['message']);
                        // } else {
                        //   CommonWidgets.snackBar('error', p['message']);
                        //   setState(() {
                        //     isDiscontinued = !isDiscontinued;
                        //   });
                        // }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class UpdatePosDialog extends StatefulWidget {
  const UpdatePosDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdatePosDialog> createState() => _UpdatePosDialogState();
}

class _UpdatePosDialogState extends State<UpdatePosDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController selectedWarehouseController = TextEditingController();
  String selectedWarehouseId = '';
  PosController posController = Get.find();
  WarehouseController warehouseController = Get.find();
  @override
  void initState() {
    nameController.text =
        '${posController.posList[widget.index]['name'] ?? ''}';
    addressController.text =
        '${posController.posList[widget.index]['address'] ?? ''}';
    selectedWarehouseId =
        '${posController.posList[widget.index]['warehouse']['id']}';
    selectedWarehouseController.text =
        '${posController.posList[widget.index]['warehouse']['name']}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // width: Sizes.deviceWidth*0.2,
      height: 300,
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
              text: '${'name'.tr}*',
              rowWidth: MediaQuery.of(context).size.width * 0.6,
              textFieldWidth: MediaQuery.of(context).size.width * 0.4,
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
              rowWidth: MediaQuery.of(context).size.width * 0.6,
              textFieldWidth: MediaQuery.of(context).size.width * 0.4,
              validationFunc: (String value) {},
            ),
            gapH16,
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: const Text('warehouse'),
                ),
                DropdownMenu<String>(
                  width: MediaQuery.of(context).size.width * 0.4,
                  // requestFocusOnTap: false,
                  enableSearch: true,
                  controller: selectedWarehouseController,
                  hintText: '${'search'.tr}...',
                  inputDecorationTheme: InputDecorationTheme(
                    // filled: true,
                    hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                    // outlineBorder: BorderSide(color: Colors.black,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(9),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Primary.primary.withAlpha((0.4 * 255).toInt()),
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
                      warehouseController.warehousesNameList
                          .map<DropdownMenuEntry<String>>((String option) {
                            return DropdownMenuEntry<String>(
                              value: option,
                              label: option,
                            );
                          })
                          .toList(),
                  enableFilter: true,
                  onSelected: (String? val) {
                    var index = warehouseController.warehousesNameList
                        .indexOf(val!);
                    setState(() {
                      selectedWarehouseId =
                          '${warehouseController.warehouseIdsList[index]}';
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      nameController.text =
                          '${posController.posList[widget.index]['name'] ?? ''}';
                      addressController.text =
                          '${posController.posList[widget.index]['address']}';
                      selectedWarehouseId =
                          '${posController.posList[widget.index]['warehouse']['id']}';
                      selectedWarehouseController.text =
                          '${posController.posList[widget.index]['warehouse']['name']}';
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
                    if (selectedWarehouseId == '') {
                      CommonWidgets.snackBar(
                        'error',
                        'you must choose warehouses first',
                      );
                    } else if (warehouseController.warehouseIdsList.contains(
                          selectedWarehouseId,
                        ) ==
                        false) {
                      CommonWidgets.snackBar(
                        'error',
                        'you must choose an existing warehouses',
                      );
                    } else if (_formKey.currentState!.validate()) {
                      var p = await updatePos(
                        '${posController.posList[widget.index]['id']}',
                        nameController.text,
                        addressController.text,
                        selectedWarehouseId,
                      );
                      if (p['success'] == true) {
                        nameController.clear();
                        Get.back();
                        CommonWidgets.snackBar('success'.tr, p['message']);
                        posController.getPossFromBack();
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
