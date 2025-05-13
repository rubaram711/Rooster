import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/Discounts/delete_discount.dart';
import 'package:rooster_app/Controllers/home_controller.dart';

import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/ConfigurationsBackend/Discounts/add_discounts.dart';
import '../../Backend/ConfigurationsBackend/Discounts/update_discount.dart';
import '../../Controllers/discounts_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/functions.dart';

// List tabsList = [
//   'general',
// ];
//
// List tabsContent = [
//   const GeneralTabInDiscounts(),
// ];

class DiscountsDialogContent extends StatefulWidget {
  const DiscountsDialogContent({super.key});

  @override
  State<DiscountsDialogContent> createState() => _DiscountsDialogContentState();
}

class _DiscountsDialogContentState extends State<DiscountsDialogContent> {
  TextEditingController valueController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  int selectedTabIndex = 0;
  bool isClicked = false;
  String type = '';
  String value = '';
  final _formKey = GlobalKey<FormState>();
  DiscountsController discountsController = Get.find();
  HomeController homeController  = Get.find();
  @override
  void initState() {
    discountsController.getDiscountsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height:homeController.isMobile.value ?MediaQuery.of(context).size.height * 0.7: MediaQuery.of(context).size.height * 0.9,
      margin:  EdgeInsets.symmetric(horizontal: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05:50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTitle(text: 'discounts'.tr),
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Wrap(
          //         spacing: 0.0,
          //         direction: Axis.horizontal,
          //         children: tabsList
          //             .map((element) => _buildTabChipItem(
          //                 element,
          //                 // element['id'],
          //                 // element['name'],
          //                 tabsList.indexOf(element)))
          //             .toList()),
          //   ],
          // ),
          _generalTabInDiscounts(),
          const Spacer(),
          isClicked
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            valueController.clear();
                            typeController.clear();
                            type = '';
                            value = '';
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
                          // if(_formKey.currentState!.validate()){
                          var p = await addDiscounts(type, value);
                          if (p['success'] == true) {
                            // Get.back();
                            discountsController.getDiscountsFromBack();
                            CommonWidgets.snackBar('', p['message']);
                            type = '';
                            value = '';
                            typeController.clear();
                            valueController.clear();
                          } else {
                            CommonWidgets.snackBar('error', p['message']);
                          }
                          // }
                        },
                        width: 100,
                        height: 35),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _generalTabInDiscounts() {
    return GetBuilder<DiscountsController>(builder: (cont) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?5: 40, vertical: 15),
            decoration: BoxDecoration(
                color: Primary.primary,
                borderRadius: const BorderRadius.all(Radius.circular(6))),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TableTitle(
                  text: 'type'.tr,
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                ),
                TableTitle(
                  text: '${'value'.tr} %',
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                ),
                // TableTitle(
                //   text: 'discontinued'.tr,
                //   width: MediaQuery.of(context).size.width * 0.06,
                // ),
                // TableTitle(
                //   text: '',
                //   width: MediaQuery.of(context).size.width * 0.5,
                // ),
              ],
            ),
          ),
          isClicked
              ? Container(
                  padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?5: 40),
                  height: 55,
                  decoration: BoxDecoration(
                      color: Primary.p10,
                      borderRadius: const BorderRadius.all(Radius.circular(0))),
                  child: Center(
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: SizedBox(
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.15,
                              child: ReusableTextField(
                                textEditingController: typeController,
                                onChangedFunc: (val) {
                                  setState(() {
                                    type = val;
                                  });
                                },
                                hint: '',
                                validationFunc: (value) {},
                                isPasswordField: false,
                                isEnable: true,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3:MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: SizedBox(
                                width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.15,
                                child: TextFormField(
                                    maxLength: 3,
                                    controller: valueController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                        counterText: '',
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 0, 25, 5),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.black.withAlpha((0.1 * 255).toInt()),
                                            width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.black.withAlpha((0.1 * 255).toInt()),
                                            width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6)),
                                      ),
                                      errorStyle: const TextStyle(
                                        fontSize: 10.0,
                                      ),
                                      focusedErrorBorder:
                                          const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)),
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.red),
                                      ),
                                    ),
                                    validator: (value) {
                                      return null;
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        value = val;
                                      });
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
                                    ])
                                // ReusableNumberField(
                                //   textEditingController: valueController,
                                //   onChangedFunc: (val) {
                                //     setState(() {
                                //       value = val;
                                //     });
                                //   },
                                //   hint: '',
                                //   validationFunc: (value) {},
                                //   isPasswordField: false,
                                //   isEnable: true,
                                // ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
          cont.isDiscountsFetched
              ? Container(
                  color: Colors.white,
                  height: cont.discountsList.length * 55,
                  child: ListView.builder(
                    itemCount: cont
                        .discountsList.length, //products is data from back res
                    itemBuilder: (context, index) => discountAsRowInTable(
                      cont.discountsList[index],
                      index,
                      cont.discountsList.length,
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
          // Container(
          //   color: Colors.white,
          //   height: newDiscountsList.length * 100,
          //   child: ListView.builder(
          //     itemCount: newDiscountsList.length, //products is data from back res
          //     itemBuilder: (context, index) => newDiscountAsRowInTable(
          //       newDiscountsList[index],
          //       index,
          //       newDiscountsList.length,
          //     ),
          //   ),
          // ),
          gapH10,
          isClicked
              ? const SizedBox()
              : ReusableAddCard(
                  text: 'new_discount'.tr,
                  onTap: () {
                    setState(() {
                      isClicked = true;
                    });
                  },
                ),
        ],
      );
    });
  }

  discountAsRowInTable(Map info, int index, int altCodesListLength) {
    return GetBuilder<DiscountsController>(builder: (cont) {
      return InkWell(
        onDoubleTap: () {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  elevation: 0,
                  content: UpdateDiscountDialog(
                    index: index,
                  )));
        },
        child: Container(
          height: 55,
          padding:   EdgeInsets.symmetric(
            horizontal:homeController.isMobile.value?5: 40,
          ),
          decoration: BoxDecoration(
              color: (index % 2 != 0) ? Primary.p10 : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0))),
          child: Center(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TableItem(
                  text: '${info['type'] ?? ''}',
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                ),
                TableItem(
                  text: info['discount_value']!=null?numberWithComma('${info['discount_value']}'): '',
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: InkWell(
                    onTap: () async {
                      var res = await deleteDiscount(
                          '${cont.discountsList[index]['id']}');
                      var p = json.decode(res.body);
                      if (res.statusCode == 200) {
                        CommonWidgets.snackBar('Success', p['message']);
                        // warehouseController.resetValues();
                        cont.getDiscountsFromBack();
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
        ),
      );
    });
  }

  newDiscountAsRowInTable(Map altCode, int index, int altCodesListLength) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Form(
        key: _formKey,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
              child: ReusableTextField(
                textEditingController: typeController,
                onChangedFunc: (val) {},
                hint: '',
                validationFunc: (String val) {
                  if (val.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
                isPasswordField: false,
                isEnable: true,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
              child: ReusableTextField(
                textEditingController: valueController,
                onChangedFunc: (val) {},
                hint: '',
                validationFunc: (String val) {
                  if (val.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
                isPasswordField: false,
                isEnable: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// class GeneralTabInDiscounts extends StatefulWidget {
//   const GeneralTabInDiscounts({super.key});
//
//   @override
//   State<GeneralTabInDiscounts> createState() => _GeneralTabInDiscountsState();
// }
//
// class _GeneralTabInDiscountsState extends State<GeneralTabInDiscounts> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//           decoration: BoxDecoration(
//               color: Primary.primary,
//               borderRadius: const BorderRadius.all(Radius.circular(6))),
//           child: Row(
//             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TableTitle(
//                 text: 'type'.tr,
//                 width: MediaQuery.of(context).size.width * 0.1,
//               ),
//               TableTitle(
//                 text: 'value'.tr,
//                 width: MediaQuery.of(context).size.width * 0.1,
//               ),
//               // TableTitle(
//               //   text: 'discontinued'.tr,
//               //   width: MediaQuery.of(context).size.width * 0.06,
//               // ),
//               // TableTitle(
//               //   text: '',
//               //   width: MediaQuery.of(context).size.width * 0.5,
//               // ),
//             ],
//           ),
//         ),
//         isClicked
//             ? Container(
//           padding: const EdgeInsets.symmetric(horizontal: 40),
//           height: 55,
//           decoration: BoxDecoration(
//               color:
//               (discountsList.length % 2 == 0) ?  Colors.white :Primary.p10 ,
//               borderRadius: const BorderRadius.all(Radius.circular(0))),
//           child: Center(
//             child: Row(
//               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.1,
//                   child: Center(
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.07,
//                       child: ReusableTextField(
//                         textEditingController: typeController,
//                         onChangedFunc: (val) {
//                           setState(() {
//                             type = val;
//                           });
//                         },
//                         hint: 'type',
//                         validationFunc: () {},
//                         isPasswordField: false,
//                         isEnable: true,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.1,
//                   child: Center(
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.07,
//                       child: ReusableNumberField(
//                         textEditingController: valueController,
//                         onChangedFunc: (val) {
//                           setState(() {
//                             value = val;
//                           });
//                         },
//                         hint: 'value',
//                         validationFunc: () {},
//                         isPasswordField: false,
//                         isEnable: true,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )
//             : const SizedBox(),
//         Container(
//           color: Colors.white,
//           height: discountsList.length * 50,
//           child: ListView.builder(
//             itemCount: discountsList.length, //products is data from back res
//             itemBuilder: (context, index) => discountAsRowInTable(
//               discountsList[index],
//               index,
//               discountsList.length,
//             ),
//           ),
//         ),
//         // Container(
//         //   color: Colors.white,
//         //   height: newDiscountsList.length * 100,
//         //   child: ListView.builder(
//         //     itemCount: newDiscountsList.length, //products is data from back res
//         //     itemBuilder: (context, index) => newDiscountAsRowInTable(
//         //       newDiscountsList[index],
//         //       index,
//         //       newDiscountsList.length,
//         //     ),
//         //   ),
//         // ),
//        gapH10,
//        isClicked
//            ?const SizedBox()
//            : InkWell(
//           onTap: () {
//             setState(() {
//               isClicked = true;
//             });
//           },
//           child: Row(
//             children: [
//               Icon(
//                 Icons.add_circle_rounded,
//                 color: Primary.primary,
//               ),
//               gapW6,
//               Text('new_discount'.tr,
//                   style: TextStyle(
//                     color: TypographyColor.textTable,
//                   ))
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   discountAsRowInTable(Map altCode, int index, int altCodesListLength) {
//     return Container(
//       height: 55,
//       padding: const EdgeInsets.symmetric(horizontal: 40,),
//       decoration: BoxDecoration(
//           color: (index % 2 == 0) ? Primary.p10 : Colors.white,
//           borderRadius: const BorderRadius.all(Radius.circular(0))),
//       child: Center(
//         child: Row(
//           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TableItem(
//               text: '${altCode['type'] ?? ''}',
//               width: MediaQuery.of(context).size.width * 0.1,
//             ),
//             TableItem(
//               text: '${altCode['value'] ?? ''}',
//               width: MediaQuery.of(context).size.width * 0.1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   newDiscountAsRowInTable(Map altCode, int index, int altCodesListLength) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//       decoration: BoxDecoration(
//           color: (index % 2 == 0) ? Primary.p10 : Colors.white,
//           borderRadius: const BorderRadius.all(Radius.circular(0))),
//       child: Row(
//         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.07,
//             child: ReusableTextField(
//               textEditingController: typeController,
//               onChangedFunc: () {},
//               hint: '',
//               validationFunc: () {},
//               isPasswordField: false,
//               isEnable: true,
//             ),
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width * 0.07,
//             child: ReusableTextField(
//               textEditingController: valueController,
//               onChangedFunc: () {},
//               hint: '',
//               validationFunc: () {},
//               isPasswordField: false,
//               isEnable: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class UpdateDiscountDialog extends StatefulWidget {
  const UpdateDiscountDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdateDiscountDialog> createState() => _UpdateDiscountDialogState();
}

class _UpdateDiscountDialogState extends State<UpdateDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController typeController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  DiscountsController discountsController = Get.find();
  @override
  void initState() {
    typeController.text =
        '${discountsController.discountsList[widget.index]['type'] ?? ''}';
    valueController.text =
        '${discountsController.discountsList[widget.index]['discount_value']}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                textEditingController: typeController,
                text: '${'type'.tr}*',
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
              DialogNumericTextField(
                textEditingController: valueController,
                text: '${'value'.tr}*',
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
                          typeController.text =
                              '${discountsController.discountsList[widget.index]['type'] ?? ''}';
                          valueController.text =
                              '${discountsController.discountsList[widget.index]['discount_value']}';
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
                          var p = await updateDiscount(
                              '${discountsController.discountsList[widget.index]['id']}',
                              typeController.text,
                              valueController.text);
                          if (p['success'] == true) {
                            typeController.clear();
                            Get.back();
                            CommonWidgets.snackBar('success'.tr, p['message']);
                            discountsController.getDiscountsFromBack();
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
