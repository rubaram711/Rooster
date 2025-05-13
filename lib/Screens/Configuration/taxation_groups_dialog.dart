import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/TaxationGroup/add_taxation_group.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/TaxationGroup/delete_taxation_group.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/TaxationGroup/update_taxation_group.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/taxation_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/ConfigurationsBackend/TaxationGroup/add_rate.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../../const/functions.dart';

List tabsList = ['general', 'rates'];

List tabsContent = [
  const GeneralTabInTaxationGroups(),
  const RateTabInTaxationGroups(),
];

class TaxationGroupsDialogContent extends StatefulWidget {
  const TaxationGroupsDialogContent({super.key});

  @override
  State<TaxationGroupsDialogContent> createState() =>
      _TaxationGroupsDialogContentState();
}

class _TaxationGroupsDialogContentState
    extends State<TaxationGroupsDialogContent> {
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTitle(text: 'taxation_groups'.tr),
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
          tabsContent[selectedTabIndex],
          // const Spacer(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     TextButton(
          //         onPressed: () {
          //           setState(() {
          //            if(selectedTabIndex==0){
          //              codeController.clear();
          //              nameController.clear();
          //            }else{
          //             vatController.clear();}
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
          //         onTapFunction: () async{
          //           if(_formKey.){
          //             var p = await addTaxationGroup(
          //                 nameController.text, codeController.text);
          //             if (p['success'] == true) {
          //               // Get.back();
          //               discountsController.getDiscountsFromBack();
          //               CommonWidgets.snackBar('', p['message']);
          //               typeController.clear();
          //               valueController.clear();
          //             } else {
          //               CommonWidgets.snackBar('error', p['message']);
          //             }
          //           }
          //         },
          //         width: 100,
          //         height: 35),
          //   ],
          // )
        ],
      ),
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: ClipPath(
        clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9)))),
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.09,
          // height: MediaQuery.of(context).size.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          decoration: BoxDecoration(
              color: selectedTabIndex == index ? Primary.p20 : Colors.white,
              border: selectedTabIndex == index
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
}

TextEditingController codeController = TextEditingController();
TextEditingController nameController = TextEditingController();

class GeneralTabInTaxationGroups extends StatefulWidget {
  const GeneralTabInTaxationGroups({super.key});

  @override
  State<GeneralTabInTaxationGroups> createState() =>
      _GeneralTabInTaxationGroupsState();
}

class _GeneralTabInTaxationGroupsState
    extends State<GeneralTabInTaxationGroups> {
  // List taxationGroupsList = [
  //   {
  //     'code': 'STANDARD',
  //     'name': 'Standard Taxation Group',
  //   }
  // ];
  bool isClicked = false;

  final _formKey = GlobalKey<FormState>();
  TaxationGroupsController taxationGroupsController =
      Get.find();
  HomeController homeController=Get.find();
  @override
  void initState() {
    taxationGroupsController.getAllTaxationGroupsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxationGroupsController>(builder: (cont) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  padding:
                        EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?5: 40, vertical: 15),
                  decoration: BoxDecoration(
                      color: Primary.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(6))),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TableTitle(
                        text: 'code'.tr,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                      TableTitle(
                        text: 'name'.tr,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                      // TableTitle(
                      //   text: '',
                      //   width: MediaQuery.of(context).size.width * 0.3,
                      // ),
                      TableTitle(
                        text: '',
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ],
                  ),
                ),
                isClicked
                    ? Container(
                        padding:   EdgeInsets.symmetric(
                            horizontal:homeController.isMobile.value ?5: 40, vertical: 15),
                        // height: 55,
                        decoration: BoxDecoration(
                            color: Primary.p10,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(0))),
                        child: Form(
                          key: _formKey,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DialogTextField(
                                textEditingController: codeController,
                                text: '',
                                rowWidth:
                                    MediaQuery.of(context).size.width * 0.25,
                                textFieldWidth:
                                    MediaQuery.of(context).size.width * 0.24,
                                validationFunc: (val) {},
                              ),
                              DialogTextField(
                                textEditingController: nameController,
                                text: '',
                                rowWidth:
                                    MediaQuery.of(context).size.width * 0.25,
                                textFieldWidth:
                                    MediaQuery.of(context).size.width * 0.24,
                                validationFunc: (val) {},
                              ),
                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width * 0.3,
                              // ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
                cont.isTaxationGroupsFetched
                    ? Container(
                        color: Colors.white,
                        height: cont.taxationGroupsList.length > 6
                            ? MediaQuery.of(context).size.height * 0.45
                            : cont.taxationGroupsList.length * 55,
                        child: ListView.builder(
                          itemCount: cont.taxationGroupsList
                              .length, //products is data from back res
                          itemBuilder: (context, index) =>
                              taxationGroupAsRowInTable(
                            cont.taxationGroupsList[index],
                            index,
                            cont.taxationGroupsList.length,
                          ),
                        ),
                      )
                    : loading(),
                isClicked
                    ? const SizedBox()
                    : ReusableAddCard(
                        text: 'new'.tr,
                        onTap: () {
                          setState(() {
                            isClicked = true;
                          });
                        },
                      ),
              ],
            ),
            isClicked
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            codeController.clear();
                            nameController.clear();
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
                              var p = await addTaxationGroup(
                                  nameController.text, codeController.text);
                              if (p['success'] == true) {
                                setState(() {
                                  isClicked = false;
                                });
                                cont.getAllTaxationGroupsFromBack();
                                CommonWidgets.snackBar('', p['message']);
                                codeController.clear();
                                nameController.clear();
                              } else {
                                CommonWidgets.snackBar('error', p['message']);
                              }
                            }
                          },
                          width: 100,
                          height: 35),
                    ],
                  )
                : const SizedBox()
          ],
        ),
      );
    });
  }

  taxationGroupAsRowInTable(Map info, int index, int altCodesListLength) {
    return GetBuilder<TaxationGroupsController>(builder: (cont) {
      return InkWell(
        onTap: () {
          cont.setSelectedTaxationGroupIndex(index);
          cont.setRatesInTaxationGroupLis(info['tax_rates']);
        },
        onDoubleTap: () {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  elevation: 0,
                  content: UpdateTaxationGroupsDialog(
                    index: index,
                  )));
        },
        child: Container(
          padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?5: 40, vertical: 10),
          decoration: BoxDecoration(
              color: cont.selectedTaxationGroupIndex == index
                  ? Primary.p10
                  : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0))),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TableItem(
                text: '${info['code'] ?? ''}',
                width: MediaQuery.of(context).size.width * 0.25,
              ),
              TableItem(
                text: '${info['name'] ?? ''}',
                width: MediaQuery.of(context).size.width * 0.25,
              ),
              // TableItem(
              //   text: '',
              //   width: MediaQuery.of(context).size.width * 0.3,
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    var res = await deleteTaxationGroup('${info['id']}');
                    var p = json.decode(res.body);
                    if (res.statusCode == 200) {
                      taxationGroupsController.getAllTaxationGroupsFromBack();
                      CommonWidgets.snackBar('Success', p['message']);
                    } else {
                      CommonWidgets.snackBar('error', p['message']);
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
    });
  }
}

TextEditingController vatController = TextEditingController();
TextEditingController startDateController = TextEditingController();

class RateTabInTaxationGroups extends StatefulWidget {
  const RateTabInTaxationGroups({super.key});

  @override
  State<RateTabInTaxationGroups> createState() =>
      _RateTabInTaxationGroupsState();
}

class _RateTabInTaxationGroupsState extends State<RateTabInTaxationGroups> {
  bool isClicked = false;
  final _formKey = GlobalKey<FormState>();
  TaxationGroupsController taxationGroupsController =
      Get.find();
  HomeController homeController=Get.find();
  String startDate = '';
  @override
  void initState() {
    // taxationGroupsController.getAllTaxationGroupsFromBack();
    startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxationGroupsController>(builder: (cont) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding:   EdgeInsets.symmetric(horizontal: homeController.isMobile.value ?5:40, vertical: 15),
              decoration: BoxDecoration(
                  color: Primary.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(6))),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TableTitle(
                    text: 'start_date'.tr,
                    width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                  ),
                  TableTitle(
                    text: '${'vat'.tr} %',
                    width: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3:MediaQuery.of(context).size.width * 0.15,
                  ),
                  // TableTitle(
                  //   text: '',
                  //   width: MediaQuery.of(context).size.width * 0.47,
                  // ),
                  // TableTitle(
                  //   text: '',
                  //   width: MediaQuery.of(context).size.width * 0.03,
                  // ),
                ],
              ),
            ),
            isClicked
                ? Container(
                    padding:   EdgeInsets.symmetric(
                        horizontal:homeController.isMobile.value ?5: 40, vertical: 15),
                    // height: 55,
                    decoration: BoxDecoration(
                        color: Primary.p10,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(0))),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width * 0.15,
                          //   child: Center(
                          //     child: Text(
                          //         DateFormat('yyyy-MM-dd').format(DateTime.now())),
                          //   ),
                          // ),
                          SizedBox(
                            width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                            child: Center(
                              child: DialogDateTextField(
                                onChangedFunc: (value) {},
                                onDateSelected: (value) {
                                 setState(() {
                                   startDate = value;
                                   startDateController.text=value;
                                 });
                                },
                                textEditingController: startDateController,
                                text: '',
                                textFieldWidth:
                                homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28:MediaQuery.of(context).size.width * 0.12,
                                validationFunc: (String val) {
                                  if (val.isEmpty) {
                                    return 'required_field'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          DialogNumericTextField(
                            textEditingController: vatController,
                            text: '',
                            rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                            textFieldWidth:
                            homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.12,
                            validationFunc: (val) {},
                          ),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width * 0.47,
                          // ),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width * 0.03,
                          // ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            Container(
              color: Colors.white,
              height: cont.ratesInTaxationGroupList.length < 6
                  ? cont.ratesInTaxationGroupList.length * 55
                  : MediaQuery.of(context).size.height * 0.4,
              child: ListView.builder(
                itemCount: cont.ratesInTaxationGroupList.length,
                itemBuilder: (context, index) => rateAsRowInTable(
                  cont.ratesInTaxationGroupList[index],
                  index,
                  cont.ratesInTaxationGroupList.length,
                ),
              ),
            ),
            isClicked
                ? const SizedBox()
                : ReusableAddCard(
                    text: 'new_rate'.tr,
                    onTap: () {
                      setState(() {
                        isClicked = true;
                      });
                    },
                  ),
            isClicked
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            vatController.clear();
                            startDateController.text =
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
                            if (_formKey.currentState!.validate()) {
                              var p = await addRate(
                                  '${cont.taxationGroupsList[cont.selectedTaxationGroupIndex]['id']}',
                                  vatController.text,
                                  startDateController.text
                                  // DateFormat('yyyy-MM-dd').format(DateTime.now())
                                  );
                              if (p['success'] == true) {
                                setState(() {
                                  isClicked = false;
                                });
                                // Get.back();
                                cont.setSelectedTaxationGroupIndex(
                                    cont.selectedTaxationGroupIndex);
                                cont.getAllTaxationGroupsFromBack();
                                CommonWidgets.snackBar('', p['message']);
                                vatController.clear();
                              } else {
                                CommonWidgets.snackBar('error', p['message']);
                              }
                            }
                          },
                          width: 100,
                          height: 35),
                    ],
                  )
                : const SizedBox()
          ],
        ),
      );
    });
  }

  rateAsRowInTable(Map info, int index, int altCodesListLength) {
    return Container(
      padding:   EdgeInsets.symmetric(horizontal: homeController.isMobile.value ?5:40, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: '${info['start_date'] ?? ''}'.length > 10
                ? '${info['start_date'] ?? ''}'.substring(0, 10)
                : '',
            width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
          ),
          TableItem(
            text:  info['tax_rate']!=null?numberWithComma('${info['tax_rate']}'): '',
            width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
          ),
          // TableItem(
          //   text: '',
          //   width: MediaQuery.of(context).size.width * 0.47,
          // ),
          // SizedBox(
          //   width: MediaQuery.of(context).size.width * 0.03,
          //   child: InkWell(
          //     onTap: () {
          //       setState(() {
          //         // altCodesList.removeAt(index);
          //       });
          //     },
          //     child: Icon(
          //       Icons.delete_outline,
          //       color: Primary.primary,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class UpdateTaxationGroupsDialog extends StatefulWidget {
  const UpdateTaxationGroupsDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdateTaxationGroupsDialog> createState() =>
      _UpdateTaxationGroupsDialogState();
}

class _UpdateTaxationGroupsDialogState
    extends State<UpdateTaxationGroupsDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TaxationGroupsController taxationGroupController = Get.find();
  @override
  void initState() {
    nameController.text =
        '${taxationGroupController.taxationGroupsList[widget.index]['name'] ?? ''}';
    codeController.text =
        '${taxationGroupController.taxationGroupsList[widget.index]['code'] ?? ''}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              gapH20,
              DialogTextField(
                textEditingController: codeController,
                text: 'code'.tr,
                rowWidth: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                validationFunc: (String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
              ),
              gapH16,
              DialogTextField(
                textEditingController: nameController,
                text: '${'name'.tr}*',
                rowWidth: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                validationFunc: (String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          nameController.text =
                              '${taxationGroupController.taxationGroupsList[widget.index]['name'] ?? ''}';
                          codeController.text =
                              '${taxationGroupController.taxationGroupsList[widget.index]['code'] ?? ''}';
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
                          var p = await updateTaxationGroup(
                            '${taxationGroupController.taxationGroupsList[widget.index]['id']}',
                            nameController.text,
                            codeController.text,
                          );
                          if (p['success'] == true) {
                            Get.back();
                            taxationGroupController
                                .getAllTaxationGroupsFromBack();
                            nameController.clear();
                            codeController.clear();
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
        ));
  }
}
