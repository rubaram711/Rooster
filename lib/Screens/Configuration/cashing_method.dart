import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/CashingMethods/delete_cashing_method.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/update_cashing_method.dart';
import 'package:rooster_app/Controllers/cashing_methods_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/ConfigurationsBackend/CashingMethods/add_cashing_method.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';


List tabsList = [
  'cashing_methods',
  'create_cashing_methods',
];

List tabsContent = [
  const CashingMethodsTable(),
  const CreateCashingMethods(),
];

class CashingMethodsDialogContent extends StatefulWidget {
  const CashingMethodsDialogContent({super.key});

  @override
  State<CashingMethodsDialogContent> createState() =>
      _CashingMethodsDialogContentState();
}

class _CashingMethodsDialogContentState
    extends State<CashingMethodsDialogContent> {
  CashingMethodsController cashingMethodsController = Get.find();
  HomeController homeController = Get.find();
  bool isAddNewClicked = false;
  List changedCashingMethodList = [];
  @override
  void initState() {
    cashingMethodsController.getCashingMethodsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashingMethodsController>(
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
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(text: 'cashing_methods'.tr),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Wrap(
                      spacing: 0.0,
                      direction: Axis.horizontal,
                      children: tabsList
                          .map((element) => _buildTabChipItem(
                              element,
                              // element['id'],
                              // element['name'],
                              tabsList.indexOf(element)))
                          .toList()),
                ],
              ),
              tabsContent[cont.selectedTabIndex],
              // _cashingMethodsTable(),
              // const Spacer(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     TextButton(
              //         onPressed: () {
              //           setState(() {
              //             titleController.clear();
              //             isCashedMethodChecked=false;
              //           });
              //         },
              //         child: Text(
              //           'discard'.tr,
              //           style: TextStyle(
              //               decoration: TextDecoration.underline,
              //               color: Primary.primary),
              //         )),
              //     gapW24,
              //     ReusableButtonWithColor(
              //         btnText: 'save'.tr,
              //         onTapFunction: () async {
              //           if (_formKey.currentState!.validate()) {
              //             if(isAddNewClicked) {
              //               var p = await addCashedMethod(titleController.text,
              //                   isCashedMethodChecked ? '1' : '0');
              //               if (p['success'] == true) {
              //                 Get.back();
              //                 CommonWidgets.snackBar('success'.tr,
              //                     'Cashing Method is added successfully');
              //               } else {
              //                 CommonWidgets.snackBar(
              //                     'error', 'error'.tr);
              //               }
              //             }
              //             if(changedCashingMethodList.isNotEmpty){
              //               // updateCashingMethod
              //             }
              //           }
              //         },
              //         width: 100,
              //         height: 35),
              //   ],
              // ),
              // gapH24,
              // _cashingMethodsTable()
            ],
          ),
        );
      }
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<CashingMethodsController>(
      builder: (cont) {
        return GestureDetector(
          onTap: () {
            // setState(() {
            cont.setSelectedTabIndex(index);
            // });
          },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(9),
                        topRight: Radius.circular(9)))),
            child:homeController.isMobile.value ?
            Container(
               width: MediaQuery.of(context).size.width * 0.34,
              height: MediaQuery.of(context).size.height * 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
            )
                : Container(
              // width: MediaQuery.of(context).size.width * 0.09,
              // height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

  // final _formKey = GlobalKey<FormState>();
  // bool isCashedMethodChecked = false;
  // TextEditingController titleController = TextEditingController();

  // Widget _addNewCashingMethod() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             gapH20,
  //             DialogTextField(
  //               textEditingController: titleController,
  //               text: '${'title'.tr}*',
  //               rowWidth: MediaQuery.of(context).size.width * 0.3,
  //               textFieldWidth: MediaQuery.of(context).size.width * 0.25,
  //               validationFunc: (String value) {
  //                 if (value.isEmpty) {
  //                   return 'required_field'.tr;
  //                 }
  //               },
  //             ),
  //             gapH16,
  //             Row(
  //               children: [
  //                 Text('active'.tr),
  //                 gapW28,
  //                 Checkbox(
  //                   // checkColor: Colors.white,
  //                   // fillColor: MaterialStateProperty.resolveWith(getColor),
  //                   value: isCashedMethodChecked,
  //                   onChanged: (bool? value) {
  //                     setState(() {
  //                       isCashedMethodChecked = value!;
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _cashingMethodsTable(){
  //   return SizedBox(
  //      width: MediaQuery.of(context).size.width * 0.5,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.symmetric(  vertical: 15),
  //           decoration: BoxDecoration(
  //               color: Primary.primary,
  //               borderRadius: const BorderRadius.all(Radius.circular(6))),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               TableTitle(
  //                 text: 'name'.tr,
  //                 width: MediaQuery.of(context).size.width * 0.2,
  //               ),
  //               TableTitle(
  //                 text: 'active'.tr,
  //                 width: MediaQuery.of(context).size.width * 0.2,
  //               ),
  //             ],
  //           ),
  //         ),
  //         isAddNewClicked
  //             ? Form(
  //               key: _formKey,
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(  vertical: 10),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     SizedBox(
  //                       width: MediaQuery.of(context).size.width * 0.19,
  //                       child: ReusableTextField(
  //                         textEditingController: titleController,
  //                         onChangedFunc: (val) {},
  //                         hint: 'name',
  //                         validationFunc: (String value) {
  //                           if (value.isEmpty) {
  //                             return 'required_field'.tr;
  //                           }return null;
  //                         },
  //                         isPasswordField: false,
  //                         isEnable: true,
  //                       ),
  //                     ),
  //                     Center(
  //                       child: SizedBox(
  //                         width: MediaQuery.of(context).size.width * 0.2,
  //                         child:  Checkbox(
  //                           value: isCashedMethodChecked,
  //                           onChanged: (bool? value) {
  //                             setState(() {
  //                               isCashedMethodChecked = value!;
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             )
  //             : const SizedBox(),
  //         GetBuilder<CashingMethodsController>(
  //           builder: (cont) {
  //             return cont.isCashingMethodsFetched? Container(
  //               color: Colors.white,
  //               height: MediaQuery.of(context).size.height * 0.5,
  //               child: ListView.builder(
  //                 itemCount:cont.cashingMethodsList.length, //products is data from back res
  //                 itemBuilder: (context, index) => CashingMethodAsRowInTable(
  //                   // data: cont.cashingMethodsList[index],
  //                   index: index,
  //                 ),
  //               ),
  //             ):loading();
  //           }
  //         ),
  //         gapH20,
  //         isAddNewClicked
  //             ?const SizedBox()
  //             : InkWell(
  //           onTap: () {
  //             setState(() {
  //               isAddNewClicked = true;
  //             });
  //           },
  //           child: Row(
  //             children: [
  //               Icon(
  //                 Icons.add_circle_rounded,
  //                 color: Primary.primary,
  //               ),
  //               gapW6,
  //               Text('new_cashing_method'.tr,
  //                   style: TextStyle(
  //                     color: TypographyColor.textTable,
  //                   ))
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class CashingMethodsTable extends StatelessWidget {
  const CashingMethodsTable({super.key});


  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();
    return SizedBox(
      width:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.8:MediaQuery.of(context).size.width * 0.5,
      height:homeController.isMobile.value ?MediaQuery.of(context).size.height* 0.6: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                color: Primary.primary,
                borderRadius: const BorderRadius.all(Radius.circular(6))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TableTitle(
                  text: 'name'.tr,
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                TableTitle(
                  text: 'active'.tr,
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                TableTitle(
                  text: ''.tr,
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
              ],
            ),
          ),
          GetBuilder<CashingMethodsController>(builder: (cont) {
            return cont.isCashingMethodsFetched
                ? Container(
                    color: Colors.white,
                    height: homeController.isMobile.value ?MediaQuery.of(context).size.height* 0.5:MediaQuery.of(context).size.height * 0.55,
                    child: ListView.builder(
                      itemCount: cont.cashingMethodsList
                          .length, //products is data from back res
                      itemBuilder: (context, index) =>
                          CashingMethodAsRowInTable(
                        // data: cont.cashingMethodsList[index],
                        index: index,
                      ),
                    ),
                  )
                : loading();
          }),
        ],
      ),
    );
  }
}

class CashingMethodAsRowInTable extends StatefulWidget {
  const CashingMethodAsRowInTable({super.key, required this.index});
  final int index;

  @override
  State<CashingMethodAsRowInTable> createState() =>
      _CashingMethodAsRowInTableState();
}

class _CashingMethodAsRowInTableState extends State<CashingMethodAsRowInTable> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashingMethodsController>(builder: (cont) {
      return InkWell(
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
                      content: UpdateCashedMethodDialog(index:widget.index,)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TableItem(
                text: '${cont.cashingMethodsList[widget.index]['title'] ?? ''}',
                width: MediaQuery.of(context).size.width * 0.15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Checkbox(
                  value:
                      '${cont.cashingMethodsList[widget.index]['active']}' == '1',
                  onChanged: (bool? value) async {
                    cont.setActiveInCashingMethod(
                        value! ? '1' : '0', widget.index);
                    var p = await updateCashingMethod(
                        '${cont.cashingMethodsList[widget.index]['id']}',
                        cont.cashingMethodsList[widget.index]['title'], //titleController.text,
                        value ? '1' : '0');
                    if (p['success'] == true) {
                      // Get.back();
                      CommonWidgets.snackBar('success'.tr, p['message']);
                    } else {
                      CommonWidgets.snackBar('error', p['message']);
                    }
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: InkWell(
                  onTap: () async{
                    var res = await deleteCashingMethod(
                        '${cont.cashingMethodsList[widget.index]['id']}');
                    var p = json.decode(res.body);
                    if (res.statusCode == 200) {
                      CommonWidgets.snackBar('Success',
                          p['message']);
                      // warehouseController.resetValues();
                      cont.getCashingMethodsFromBack();
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
              )
            ],
          ),
        ),
      );
    });
  }
}

class CreateCashingMethods extends StatefulWidget {
  const CreateCashingMethods({super.key});

  @override
  State<CreateCashingMethods> createState() => _CreateCashingMethodsState();
}

class _CreateCashingMethodsState extends State<CreateCashingMethods> {
  final _formKey = GlobalKey<FormState>();
  bool isCashedMethodChecked = false;
  TextEditingController titleController = TextEditingController();
  CashingMethodsController cashingMethodsController = Get.find();
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:homeController.isMobile.value ?MediaQuery.of(context).size.height* 0.6: MediaQuery.of(context).size.height * 0.65,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            gapH20,
            DialogTextField(
              textEditingController: titleController,
              text: '${'title'.tr}*',
              rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width* 0.6: MediaQuery.of(context).size.width * 0.35,
              textFieldWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width* 0.4: MediaQuery.of(context).size.width * 0.25,
              validationFunc: (String value) {
                if (value.isEmpty) {
                  return 'required_field'.tr;
                }return null;
              },
            ),
            gapH16,
            Row(
              children: [
                Text('active'.tr),
                gapW28,
                Checkbox(
                  // checkColor: Colors.white,
                  // fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: isCashedMethodChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isCashedMethodChecked = value!;
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
                        titleController.clear();
                        isCashedMethodChecked = false;
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
                        var p = await addCashedMethod(titleController.text,
                            isCashedMethodChecked ? '1' : '0');
                        if (p['success'] == true) {
                          // Get.back();
                          CommonWidgets.snackBar('success'.tr,
                              p['message']);
                          cashingMethodsController.setSelectedTabIndex(0);
                          cashingMethodsController.getCashingMethodsFromBack();
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
      ),
    );
  }
}






class UpdateCashedMethodDialog extends StatefulWidget {
  const UpdateCashedMethodDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdateCashedMethodDialog> createState() =>
      _UpdateCashedMethodDialogState();
}

class _UpdateCashedMethodDialogState extends State<UpdateCashedMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isCashedMethodChecked = false;
  TextEditingController titleController = TextEditingController();
  CashingMethodsController cashingMethodsController = Get.find();
  HomeController homeController = Get.find();
  @override
  void initState() {
    titleController.text='${cashingMethodsController.cashingMethodsList[widget.index]['title'] ?? ''}';
    isCashedMethodChecked = '${cashingMethodsController.cashingMethodsList[widget.index]['active']}' == '1';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.white,
      // width: Sizes.deviceWidth*0.2,
      height: 250,
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
              textEditingController: titleController,
              text: '${'title'.tr}*',
              rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width* 0.6: MediaQuery.of(context).size.width * 0.3,
              textFieldWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width* 0.4: MediaQuery.of(context).size.width * 0.25,
              validationFunc: (String value) {
                if (value.isEmpty) {
                  return 'required_field'.tr;
                }return null;
              },
            ),
            gapH16,
            Row(
              children: [
                Text('active'.tr),
                gapW28,
                Checkbox(
                  value: isCashedMethodChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isCashedMethodChecked = value!;
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
                        titleController.text='${cashingMethodsController.cashingMethodsList[widget.index]['title'] ?? ''}';
                        isCashedMethodChecked = '${cashingMethodsController.cashingMethodsList[widget.index]['active']}' == '1';
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
                        var p = await updateCashingMethod(
                            '${cashingMethodsController.cashingMethodsList[widget.index]['id']}',
                             titleController.text,
                            isCashedMethodChecked ? '1' : '0');
                        if (p['success'] == true) {
                          titleController.clear();
                          Get.back();
                          CommonWidgets.snackBar('success'.tr, p['message']);
                          cashingMethodsController.getCashingMethodsFromBack();
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










