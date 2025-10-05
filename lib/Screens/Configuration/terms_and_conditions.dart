import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/TermsAndConditions/delete_terms_and_conditione.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/terms_and_conditions_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/TermsAndConditions/save_terms_and_conditions.dart';
import '../../Backend/TermsAndConditions/update_terms_and_conditions.dart';
import '../../Widgets/custom_snak_bar.dart' show CommonWidgets;
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';

import '../../const/Delta/convert_from_delta_to_widget.dart';

class TermsAndConditionsDialogContent extends StatefulWidget {
  const TermsAndConditionsDialogContent({super.key});

  @override
  State<TermsAndConditionsDialogContent> createState() =>
      _TermsAndConditionsDialogContentState();
}

class _TermsAndConditionsDialogContentState
    extends State<TermsAndConditionsDialogContent> {
  List tabsList = ['general', 'create_terms_and_conditions'];
  List tabsContent = [GeneralTabContent(), const CreateNewTermsAndConditions()];
  HomeController homeController = Get.find();
  TermsAndConditionsController termsAndConditionsController = Get.find();

  @override
  void initState() {
    termsAndConditionsController.reset();
    termsAndConditionsController.getTermsAndConditionsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TermsAndConditionsController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height:
              homeController.isMobile.value
                  ? MediaQuery.of(context).size.height * 0.7
                  : MediaQuery.of(context).size.height * 0.9,
          margin: EdgeInsets.symmetric(
            horizontal:
                homeController.isMobile.value
                    ? MediaQuery.of(context).size.width * 0.05
                    : 50,
            vertical: 30,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(text: 'terms_and_conditions'.tr),
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
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children:
                        tabsList
                            .map(
                              (element) => ReusableBuildTabChipItem(
                                index: tabsList.indexOf(element),
                                function: () {
                                  if(tabsList.indexOf(element)==1) {
                                    cont.setIsItUpdate(false);
                                    cont.reset();
                                  }
                                  cont.setSelectedTabIndex(
                                    tabsList.indexOf(element),
                                  );
                                },
                                isClicked:
                                    cont.selectedTabIndex ==
                                    tabsList.indexOf(element),
                                name: element,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              tabsContent[cont.selectedTabIndex],
            ],
          ),
        );
      },
    );
  }
}

class GeneralTabContent extends StatefulWidget {
  const GeneralTabContent({super.key});

  @override
  State<GeneralTabContent> createState() => _GeneralTabContentState();
}

class _GeneralTabContentState extends State<GeneralTabContent> {
  TermsAndConditionsController termsController = Get.find();
  HomeController homeController = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: GetBuilder<TermsAndConditionsController>(
        builder: (cont) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: homeController.isMobile.value ? 5 : 40,
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
                      isCentered: false,
                      text: 'name'.tr,
                      width:
                          homeController.isMobile.value
                              ? MediaQuery.of(context).size.width * 0.3
                              : MediaQuery.of(context).size.width * 0.2,
                    ),
                    TableTitle(
                      isCentered: false,
                      text: 'description'.tr,
                      width:
                          homeController.isMobile.value
                              ? MediaQuery.of(context).size.width * 0.3
                              : MediaQuery.of(context).size.width * 0.4,
                    ),
                  ],
                ),
              ),
              cont.isTermsAndConditionsFetched
                  ? Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: ListView.builder(
                      itemCount:
                          cont
                              .termsAndConditionsList
                              .length, //products is data from back res
                      itemBuilder:
                          (context, index) => termAndConditionsAsRowInTable(
                            cont.termsAndConditionsList[index],
                            index,
                          ),
                    ),
                  )
                  : loading(),
            ],
          );
        },
      ),
    );
  }

  termAndConditionsAsRowInTable(Map info, int index) {
    return GetBuilder<TermsAndConditionsController>(
      builder: (cont) {
        return InkWell(
          onDoubleTap: () {
            cont.setSelectedTermsAndCondition(info);
            cont.setSelectedTermsAndConditionId('${info['id']}');
            cont.setIsItUpdate(true);
            cont.setSelectedTabIndex(1);
            // showDialog<String>(
            //     context: context,
            //     builder: (BuildContext context) => AlertDialog(
            //         backgroundColor: Colors.white,
            //         shape: const RoundedRectangleBorder(
            //           borderRadius: BorderRadius.all(Radius.circular(9)),
            //         ),
            //         elevation: 0,
            //         content: UpdateTermAndConditionsDialog(
            //           index: index,
            //         )));
          },
          child: Container(
            height: 150,
            padding: EdgeInsets.symmetric(
              horizontal: homeController.isMobile.value ? 5 : 40,
            ),
            decoration: BoxDecoration(
              color: index % 2 != 0 ? Primary.p10 : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TableItem(
                  isCentered: false,
                  text: '${info['name'] ?? ''}',
                  width:
                      homeController.isMobile.value
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width * 0.2,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  width:
                      homeController.isMobile.value
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width * 0.4,
                  child: SingleChildScrollView(
                    child:
                        '${info['terms_and_conditions']}'.startsWith('[{')
                            ? quillDeltaToWidget(
                              '${info['terms_and_conditions']}',
                            )
                            : Text(info['terms_and_conditions'] ?? ''),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                      child: InkWell(
                        onTap: () async {
                          var res = await deleteTermsAndConditions(
                            '${info['id']}',
                          );
                          var p = json.decode(res.body);
                          if (res.statusCode == 200) {
                            CommonWidgets.snackBar('Success', p['message']);
                            cont.getTermsAndConditionsFromBack();
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                      child: InkWell(
                        onTap: () {
                          cont.setSelectedTermsAndCondition(info);
                          cont.setSelectedTermsAndConditionId('${info['id']}');
                          cont.setIsItUpdate(true);
                          cont.setSelectedTabIndex(1);
                        },
                        child: Icon(Icons.edit, color: Primary.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class UpdateTermAndConditionsDialog extends StatefulWidget {
//   const UpdateTermAndConditionsDialog({super.key, required this.index});
//   final int index;
//
//   @override
//   State<UpdateTermAndConditionsDialog> createState() => _UpdateTermAndConditionsDialogState();
// }
//
// class _UpdateTermAndConditionsDialogState extends State<UpdateTermAndConditionsDialog> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController descController = TextEditingController();
//   TermsAndConditionsController termsAndConditionsController = Get.find();
//   @override
//   void initState() {
//     nameController.text =
//     '${termsAndConditionsController.termsAndConditionsList[widget.index]['name'] ?? ''}';
//     descController.text =
//     '${termsAndConditionsController.termsAndConditionsList[widget.index]['description']}';
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         color: Colors.white,
//         // width: Sizes.deviceWidth*0.2,
//         height: 250,
//         // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
//         // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               gapH20,
//               DialogTextField(
//                 textEditingController: nameController,
//                 text: '${'name'.tr}*',
//                 rowWidth: MediaQuery.of(context).size.width * 0.3,
//                 textFieldWidth: MediaQuery.of(context).size.width * 0.25,
//                 validationFunc: (String value) {
//                   if (value.isEmpty) {
//                     return 'required_field'.tr;
//                   }
//                   return null;
//                 },
//               ),
//               gapH16,
//               DialogNumericTextField(
//                 textEditingController: descController,
//                 text: '${'description'.tr}*',
//                 rowWidth: MediaQuery.of(context).size.width * 0.3,
//                 textFieldWidth: MediaQuery.of(context).size.width * 0.25,
//                 validationFunc: (String value) {
//                   if (value.isEmpty) {
//                     return 'required_field'.tr;
//                   }
//                   return null;
//                 },
//               ),
//               const Spacer(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                       onPressed: () {
//                         setState(() {
//                           nameController.text =
//                           '${termsAndConditionsController.termsAndConditionsList[widget.index]['name'] ?? ''}';
//                           descController.text =
//                           '${termsAndConditionsController.termsAndConditionsList[widget.index]['description']}';
//                         });
//                       },
//                       child: Text(
//                         'discard'.tr,
//                         style: TextStyle(
//                             decoration: TextDecoration.underline,
//                             color: Primary.primary),
//                       )),
//                   gapW24,
//                   ReusableButtonWithColor(
//                       btnText: 'save'.tr,
//                       onTapFunction: () async {
//                         if (_formKey.currentState!.validate()) {
//                           // var p = await updateDiscount(//todo
//                           //     '${paymentTermsController.paymentTermsList[widget.index]['id']}',
//                           //     nameController.text,
//                           //     descController.text);
//                           // if (p['success'] == true) {
//                           //   Get.back();
//                           //   CommonWidgets.snackBar('success'.tr, p['message']);
//                           //   paymentTermsController.getPaymentTermsFromBack();
//                           // } else {
//                           //   CommonWidgets.snackBar('error', p['message']);
//                           // }
//                         }
//                       },
//                       width: 100,
//                       height: 35),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }
// }

class CreateNewTermsAndConditions extends StatefulWidget {
  const CreateNewTermsAndConditions({super.key});

  @override
  State<CreateNewTermsAndConditions> createState() =>
      _CreateNewTermsAndConditionsState();
}

class _CreateNewTermsAndConditionsState
    extends State<CreateNewTermsAndConditions> {
  int selectedTabIndex = 0;
  final HomeController homeController = Get.find();
  final TermsAndConditionsController termsController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  bool isYesClicked = false;

  String selectedGroupId = '';
  String? selectedItem = '';

  final _formKey = GlobalKey<FormState>();
  late QuillController _controller;
  String? _savedContent;

  // void _saveContent() {
  //   final deltaJson = _controller.document.toDelta().toJson();
  //   final jsonString = jsonEncode(deltaJson);
  //
  //   setState(() {
  //     _savedContent = jsonString;
  //   });
  //
  //   // You can now send `jsonString` to your backend
  //   descController.text = jsonString;
  // }
  //// Restore content from saved string (e.g., from API)
  void _loadContent() {
    if (_savedContent == null) return;

    final delta = Delta.fromJson(jsonDecode(_savedContent!));
    final doc = Document.fromDelta(delta);

    setState(() {
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
  }

  void _saveTermsAndConditions() async {
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    setState(() {
      _savedContent = jsonString;
    });
    descController.text = jsonString;

    var p = await storeTermsAndConditions(nameController.text, _savedContent!);
    if (p['success'] == true) {
      CommonWidgets.snackBar('Success', p['message']);
      termsController.getTermsAndConditionsFromBack();
      termsController.setSelectedTabIndex(0);
    } else {
      CommonWidgets.snackBar('error', p['message']);
    }
  }
  void _updateTermsAndConditions() async {
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    setState(() {
      _savedContent = jsonString;
    });
    descController.text = jsonString;

    var p = await updateTermsAndConditions('${termsController.selectedTermsAndCondition['id']}',nameController.text, _savedContent!);
    if (p['success'] == true) {
      CommonWidgets.snackBar('Success', p['message']);
      termsController.setSelectedTabIndex(0);
    } else {
      CommonWidgets.snackBar('error', p['message']);
    }
  }

  todoWhenUpdate() {
    if (termsController.isItUpdate) {
      nameController.text=termsController.selectedTermsAndCondition['name'];
      if (termsController.selectedTermsAndCondition['terms_and_conditions'] ==
              null ||
          '${termsController.selectedTermsAndCondition['terms_and_conditions']}' ==
              'null') {
        descController.text = '[{"insert":"\n"}]';
        _savedContent = '[{"insert":"\n"}]';
      } else {
        descController.text =
            termsController.selectedTermsAndCondition['terms_and_conditions'];
        _savedContent =
            termsController.selectedTermsAndCondition['terms_and_conditions'];
      }
      _loadContent();
    }
  }

  @override
  void initState() {
    nameController.text='';
    descController.text='';
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    todoWhenUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TermsAndConditionsController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH32,
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DialogTextField(
                      textEditingController: nameController,
                      text: '${'name'.tr}*',
                      rowWidth: MediaQuery.of(context).size.width * 0.6,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                      validationFunc: (String value) {
                        if (value.isEmpty) {
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH16,
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        children: [
                          QuillSimpleToolbar(
                            controller: _controller,
                            config: QuillSimpleToolbarConfig(
                              showFontFamily: false,
                              showColorButton: false,
                              showBackgroundColorButton: false,
                              showSearchButton: false,
                              showDirection: false,
                              showLink: false,
                              showAlignmentButtons: false,
                              showLeftAlignment: false,
                              showRightAlignment: false,
                              showListCheck: false,
                              showIndent: false,
                              showQuote: false,
                              showCodeBlock: false,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[100],
                              child: QuillEditor.basic(controller: _controller),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        nameController.clear();
                        descController.clear();
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
                      if(termsController.isItUpdate){
                        _updateTermsAndConditions();
                      }else{
                        _saveTermsAndConditions();
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
        );
      },
    );
  }
}
