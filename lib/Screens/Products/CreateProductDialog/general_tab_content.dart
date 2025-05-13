import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../../Controllers/products_controller.dart';
import '../../../Widgets/add_photo_circle.dart';
import '../../../Widgets/dialog_drop_menu.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

TextEditingController typeController = TextEditingController();
TextEditingController taxationController = TextEditingController();
TextEditingController codeController = TextEditingController();
TextEditingController mainDescriptionController = TextEditingController();
TextEditingController shortDescriptionController = TextEditingController();
TextEditingController secondLanguageController = TextEditingController();
TextEditingController dateController = TextEditingController();

class GeneralTabContent extends StatefulWidget {
  const GeneralTabContent({super.key});

  @override
  State<GeneralTabContent> createState() => _GeneralTabContentState();
}

class _GeneralTabContentState extends State<GeneralTabContent> {
  ProductController productController = Get.find();
  // List<Widget> photosList = [];
  // double photosListWidth = 0;
  final _formKey = GlobalKey<FormState>();
  late Uint8List imageFile;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child:
              cont.isProductsInfoFetched
                  ? Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 150,
                              width:
                                  cont.photosListWidth >
                                          MediaQuery.of(context).size.width *
                                              0.7
                                      ? MediaQuery.of(context).size.width * 0.7
                                      : cont.photosListWidth,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: cont.photosWidgetsMap.values.toList(),
                              ),
                            ),
                            ReusableAddPhotoCircle(
                              onTapCircle: () async {
                                final image =
                                    await ImagePickerHelper.pickImage();
                                setState(() {
                                  imageFile = image!;
                                  var index = cont.counterForImages;
                                  cont.addImageToPhotosWidgetsMap(
                                    index,
                                    ReusablePhotoCircleInProduct(
                                      imageFilePassed: imageFile,
                                      func: () {
                                        cont.removeFromImagesList(index);
                                      },
                                    ),
                                  );
                                  cont.addImageToPhotosFilesList(imageFile);
                                  cont.setPhotosListWidth(
                                    cont.photosListWidth + 130,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        gapH6,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogDropMenu(
                              controller: typeController,
                              optionsList: cont.itemTypesNames,
                              text: 'type'.tr,
                              hint:
                                  cont.itemTypesNames[cont.itemTypesIds.indexOf(
                                    cont.selectedItemTypesId,
                                  )],
                              rowWidth:
                                  MediaQuery.of(context).size.width * 0.25,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.15,
                              onSelected: (val) {
                                var index = cont.itemTypesNames.indexOf(val);
                                cont.setSelectedItemTypesId(
                                  cont.itemTypesIds[index],
                                );
                                // print(cont.itemTypesNames[cont.itemTypesIds.indexOf(cont.selectedItemTypesId)]);
                              },
                            ),
                          ],
                        ),
                        gapH6,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogTextField(
                              textEditingController: codeController,
                              text: '${'code'.tr}*',
                              rowWidth:
                                  MediaQuery.of(context).size.width * 0.25,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.15,
                              validationFunc: (value) {
                                if (value.isEmpty) {
                                  return 'required_field'.tr;
                                }
                                return null;
                              },
                              // onChangedFunc: (value){
                              //   itemNameController.text=value;
                              // },
                            ),
                            DialogTextField(
                              textEditingController: mainDescriptionController,
                              text: '${'main_description'.tr}*',
                              rowWidth: MediaQuery.of(context).size.width * 0.5,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.4,
                              validationFunc: (value) {
                                if (value.isEmpty) {
                                  return 'required_field'.tr;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        gapH6,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogTextField(
                              textEditingController: shortDescriptionController,
                              text: 'short_description'.tr,
                              rowWidth:
                                  MediaQuery.of(context).size.width * 0.25,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.15,
                              validationFunc: (val) {},
                            ),
                            DialogTextField(
                              text: 'second_language'.tr,
                              textEditingController: secondLanguageController,
                              rowWidth: MediaQuery.of(context).size.width * 0.5,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.4,
                              validationFunc: (val) {},
                            ),
                          ],
                        ),
                        gapH6,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogDropMenu(
                              controller: taxationController,
                              optionsList: cont.taxationGroupsNames,
                              text: 'taxation'.tr,
                              hint:
                                  cont.taxationGroupsNames[cont
                                      .taxationGroupsIds
                                      .indexOf(cont.selectedTaxationGroupsId)],
                              rowWidth:
                                  MediaQuery.of(context).size.width * 0.25,
                              textFieldWidth:
                                  MediaQuery.of(context).size.width * 0.15,
                              onSelected: (val) {
                                var index = cont.taxationGroupsNames.indexOf(
                                  val,
                                );
                                cont.setSelectedTaxationGroupsId(
                                  cont.taxationGroupsIds[index],
                                );
                              },
                            ),
                            gapW10,
                            // DialogDropMenu(
                            //   controller: categoryController,
                            //   optionsList: cont.categoriesNames,
                            //   text: 'category'.tr,
                            //   hint: cont.categoriesNames[cont.categoriesIds.indexOf(cont.selectedCategoryId)],
                            //   rowWidth: MediaQuery.of(context).size.width * 0.5,
                            //   textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                            //   onSelected:  (String? val) {
                            //     var index = cont.categoriesNames.indexOf(val!);
                            //     cont.setSelectedCategoryId(cont.categoriesIds[index]);
                            //   },
                            // ),
                          ],
                        ),
                        gapH6,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('sub_ref'.tr),
                            // const DialogRadioButtonsListView(),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        cont.subrefsNames[1],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Radio(
                                        value: 1,
                                        groupValue: cont.selectedSubrefsId,
                                        onChanged: (value) {
                                          cont.setSelectedSubrefsId(
                                            cont.subrefsIds[1],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        cont.subrefsNames[2],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Radio(
                                        value: 2,
                                        groupValue: cont.selectedSubrefsId,
                                        onChanged: (value) {
                                          cont.setSelectedSubrefsId(
                                            cont.subrefsIds[2],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        cont.subrefsNames[3],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Radio(
                                        value: 3,
                                        groupValue: cont.selectedSubrefsId,
                                        onChanged: (value) {
                                          cont.setSelectedSubrefsId(
                                            cont.subrefsIds[3],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        cont.subrefsNames[4],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Radio(
                                        value: 4,
                                        groupValue: cont.selectedSubrefsId,
                                        onChanged: (value) {
                                          cont.setSelectedSubrefsId(
                                            cont.subrefsIds[4],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const DialogCheckBoxesListView(),
                          ],
                        ),
                      ],
                    ),
                  )
                  : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class DialogRadioButtonsListView extends StatefulWidget {
  const DialogRadioButtonsListView({super.key});

  @override
  State<DialogRadioButtonsListView> createState() =>
      _DialogRadioButtonsListViewState();
}

class _DialogRadioButtonsListViewState
    extends State<DialogRadioButtonsListView> {
  int selectedOption = 1;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListTile(
              title: Text(
                'serial_number'.tr,
                style: const TextStyle(fontSize: 12),
              ),
              leading: Radio(
                value: 1,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text(
                'expiry_date'.tr,
                style: const TextStyle(fontSize: 12),
              ),
              leading: Radio(
                value: 2,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text('color'.tr, style: const TextStyle(fontSize: 12)),
              leading: Radio(
                value: 3,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text('size'.tr, style: const TextStyle(fontSize: 12)),
              leading: Radio(
                value: 4,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DialogCheckBoxesListView extends StatefulWidget {
  const DialogCheckBoxesListView({super.key});

  @override
  State<DialogCheckBoxesListView> createState() =>
      _DialogCheckBoxesListViewState();
}

class _DialogCheckBoxesListViewState extends State<DialogCheckBoxesListView> {
  final ProductController productController = Get.find();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GetBuilder<ProductController>(
        builder: (cont) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'can_be_sold'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: Checkbox(
                          // checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(getColor),
                          value: cont.isCanBeSoldChecked,
                          onChanged: (bool? value) {
                            cont.setIsCanBeSoldChecked(value!);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'can_be_purchased'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: Checkbox(
                          // checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(getColor),
                          value: cont.isCanBePurchasedChecked,
                          onChanged: (bool? value) {
                            cont.setIsCanBePurchasedChecked(value!);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'warranty'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: Checkbox(
                          // checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(getColor),
                          value: cont.isWarrantyChecked,
                          onChanged: (bool? value) {
                            cont.setIsWarrantyChecked(value!);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'discontinued'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: Checkbox(
                          // checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(getColor),
                          value: cont.isDiscontinuedChecked,
                          onChanged: (bool? value) {
                            cont.setIsDiscontinuedChecked(value!);
                          },
                        ),
                      ),
                    ),
                    // cont.isDiscontinuedChecked
                    //     ? DialogDateTextField(
                    //         textEditingController: dateController,
                    //         isDottedDate: false,
                    //         text: 'date'.tr,
                    //         // text: dateController.text.isEmpty||dateController.text==null ?'date'.tr:dateController.text,
                    //         textFieldWidth:
                    //             MediaQuery.of(context).size.width * 0.13,
                    //         validationFunc: (val) {},
                    //         onChangedFunc: (val) {},
                    //         onDateSelected: (val) {
                    //           dateController.text=val;
                    //         })
                    //     : const SizedBox(),
                    Expanded(
                      child: ListTile(
                        title: Text(
                          'blocked'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: Checkbox(
                          // checkColor: Colors.white,
                          // fillColor: MaterialStateProperty.resolveWith(getColor),
                          value: cont.isBlockedChecked,
                          onChanged: (bool? value) {
                            cont.setIsBlockedChecked(value!);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // is4Checked
                //     ?DialogDateTextField(
                //   text: 'date'.tr,
                //   textFieldWidth:  MediaQuery.of(context).size.width * 0.17,
                //   validationFunc: (){},
                //   onChangedFunc: (){},
                // )
                //     :const SizedBox()
              ],
            ),
          );
        },
      ),
    );
  }
}

class MobileGeneralTabContent extends StatefulWidget {
  const MobileGeneralTabContent({super.key});

  @override
  State<MobileGeneralTabContent> createState() =>
      _MobileGeneralTabContentState();
}

class _MobileGeneralTabContentState extends State<MobileGeneralTabContent> {
  ProductController productController = Get.find();
  // List<Widget> photosWidgetsList = [];
  // List photosFilesList = [];
  // double photosListWidth = 0;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // productController.getFieldsForCreateProductFromBack();
    // productController.setSelectedItemTypesId(productController.itemTypesIds[0]);
    // productController.setSelectedTaxationGroupsId(productController.taxationGroupsIds[0]);
    // productController.setPhotosListWidth(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return cont.isProductsInfoFetched
            ? Form(
              key: _formKey,
              child: ListView(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      addPhotoCircle(),
                      SizedBox(
                        height: 150,
                        width:
                            cont.photosListWidth >
                                    MediaQuery.of(context).size.width * 0.45
                                ? MediaQuery.of(context).size.width * 0.45
                                : cont.photosListWidth,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              cont.photosWidgetsMap.values
                                  .toList()
                                  .reversed
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                  gapH24,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DialogDropMenu(
                        controller: typeController,
                        optionsList: cont.itemTypesNames,
                        text: 'type'.tr,
                        hint:
                            cont.itemTypesNames[cont.itemTypesIds.indexOf(
                              cont.selectedItemTypesId,
                            )],
                        rowWidth: MediaQuery.of(context).size.width * 0.75,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                        onSelected: (val) {
                          var index = cont.itemTypesNames.indexOf(val);
                          cont.setSelectedItemTypesId(cont.itemTypesIds[index]);
                        },
                      ),
                      // gapH6,
                      // DialogTextField(
                      //   textEditingController: nameController,
                      //   text: '${'name'.tr}*',
                      //   rowWidth: MediaQuery.of(context).size.width * 0.8,
                      //   textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                      //   validationFunc: () {},
                      // ),
                      gapH6,
                      DialogTextField(
                        textEditingController: codeController,
                        text: '${'code'.tr}*',
                        rowWidth: MediaQuery.of(context).size.width * 0.75,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                        validationFunc: (value) {
                          if (value.isEmpty) {
                            return 'required_field'.tr;
                          }
                          return null;
                        },
                      ),
                      gapH6,
                      DialogTextField(
                        textEditingController: mainDescriptionController,
                        text: '${'main_description'.tr}*',
                        rowWidth: MediaQuery.of(context).size.width * 0.75,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                        validationFunc: (value) {
                          if (value.isEmpty) {
                            return 'required_field'.tr;
                          }
                          return null;
                        },
                      ),
                      gapH6,
                      DialogTextField(
                        textEditingController: shortDescriptionController,
                        text: 'short_description'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.75,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                        validationFunc: (val) {},
                      ),
                      gapH6,
                      DialogTextField(
                        text: 'second_language'.tr,
                        textEditingController: secondLanguageController,
                        rowWidth: MediaQuery.of(context).size.width * 0.75,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                        validationFunc: (val) {},
                      ),
                      gapH6,
                      DialogDropMenu(
                        controller: taxationController,
                        optionsList: cont.taxationGroupsNames,
                        text: 'taxation'.tr,
                        hint:
                            cont.taxationGroupsNames[cont.taxationGroupsIds
                                .indexOf(cont.selectedTaxationGroupsId)],
                        rowWidth: MediaQuery.of(context).size.width * 0.75,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                        onSelected: (val) {
                          var index = cont.taxationGroupsNames.indexOf(val);
                          cont.setSelectedTaxationGroupsId(
                            cont.taxationGroupsIds[index],
                          );
                        },
                      ),
                      gapH6,
                      // DialogDropMenu(
                      //   controller: categoryController,
                      //   optionsList: cont.categoriesNames,
                      //   text: 'category'.tr,
                      //   hint: cont.categoriesNames[cont.categoriesIds.indexOf(cont.selectedCategoryId)],
                      //   rowWidth: MediaQuery.of(context).size.width * 0.8,
                      //   textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      //   onSelected: (String? val) {
                      //     var index = cont.categoriesNames.indexOf(val!);
                      //     cont.setSelectedCategoryId(cont.categoriesIds[index]);
                      //   },
                      // ),
                      gapH24,
                      Text('sub_ref'.tr),
                      // const MobileDialogRadioButtonsListView(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      cont.subrefsNames[1],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Radio(
                                      value: 1,
                                      groupValue: cont.selectedSubrefsId,
                                      onChanged: (value) {
                                        cont.setSelectedSubrefsId(
                                          cont.subrefsIds[1],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      cont.subrefsNames[2],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Radio(
                                      value: 2,
                                      groupValue: cont.selectedSubrefsId,
                                      onChanged: (value) {
                                        cont.setSelectedSubrefsId(
                                          cont.subrefsIds[2],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      cont.subrefsNames[3],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Radio(
                                      value: 3,
                                      groupValue: cont.selectedSubrefsId,
                                      onChanged: (value) {
                                        cont.setSelectedSubrefsId(
                                          cont.subrefsIds[3],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      cont.subrefsNames[4],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Radio(
                                      value: 4,
                                      groupValue: cont.selectedSubrefsId,
                                      onChanged: (value) {
                                        cont.setSelectedSubrefsId(
                                          cont.subrefsIds[4],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      gapH6,
                      // const MobileDialogCheckBoxesListView()
                      Divider(
                        endIndent: 50,
                        color: CupertinoColors.extraLightBackgroundGray,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'can_be_sold'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Checkbox(
                                      // checkColor: Colors.white,
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: cont.isCanBeSoldChecked,
                                      onChanged: (bool? value) {
                                        cont.setIsCanBeSoldChecked(value!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'can_be_purchased'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Checkbox(
                                      // checkColor: Colors.white,
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: cont.isCanBePurchasedChecked,
                                      onChanged: (bool? value) {
                                        cont.setIsCanBePurchasedChecked(value!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'warranty'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Checkbox(
                                      // checkColor: Colors.white,
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: cont.isWarrantyChecked,
                                      onChanged: (bool? value) {
                                        cont.setIsWarrantyChecked(value!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'discontinued'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Checkbox(
                                      // checkColor: Colors.white,
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: cont.isDiscontinuedChecked,
                                      onChanged: (bool? value) {
                                        cont.setIsDiscontinuedChecked(value!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'blocked'.tr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    leading: Checkbox(
                                      // checkColor: Colors.white,
                                      // fillColor: MaterialStateProperty.resolveWith(getColor),
                                      value: cont.isBlockedChecked,
                                      onChanged: (bool? value) {
                                        cont.setIsBlockedChecked(value!);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // cont.isDiscontinuedChecked
                            //     ? DialogDateTextField(
                            //         textEditingController: dateController,
                            //         isDottedDate: false,
                            //         text: 'date'.tr,
                            //         // text: dateController.text.isEmpty||dateController.text==null ?'date'.tr:dateController.text,
                            //         textFieldWidth:
                            //             MediaQuery.of(context).size.width * 0.5,
                            //         validationFunc: (val) {},
                            //         onChangedFunc: (val) {},
                            //         onDateSelected: (val) {
                            //           dateController.text=val;
                            //         })
                            //     : const SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // const Spacer(),
                  // ReusableBTNsRow(
                  //   onBackClicked: (){},
                  //   onDiscardClicked: (){
                  //     cont.discardInGeneral();
                  //   },
                  //   onNextClicked: (){
                  //     if(_formKey.currentState!.validate()) {
                  //       cont.setSelectedTabIndex(1);
                  //     }
                  //   },
                  //   onSaveClicked: (){},
                  //   isTheFirstTab: true,
                  // )
                ],
              ),
            )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  late Uint8List imageFile;
  addPhotoCircle() {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return InkWell(
          onTap: () async {
            final image = await ImagePickerHelper.pickImage();
            setState(() {
              imageFile = image!;
              var index = cont.counterForImages;
              cont.addImageToPhotosWidgetsMap(
                index,
                photoCircle(imageFile,() {
                  cont.removeFromImagesList(index);
                  cont.removeImageFromPhotosFilesList(imageFile);
                },),
              );
              // cont.addImageToPhotosWidgetsList(photoCircle(imageFile));
              cont.addImageToPhotosFilesList(imageFile);
              cont.setPhotosListWidth(cont.photosListWidth + 130);
              // cont.addImageToPhotosFilesList(imageFile);
              // cont.changeBoolVar(true);
              // cont.increaseImageSpace(90);
              // listViewLength = listViewLength + (cont.imageSpaceHeight) + 10;
            });
          },
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Primary.p20,
            child: DottedBorder(
              borderType: BorderType.Circle,
              color: Primary.primary,
              dashPattern: const [5, 10],
              child: Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    String.fromCharCode(Icons.add_rounded.codePoint),
                    style: TextStyle(
                      inherit: false,
                      color: Primary.primary,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      fontFamily: Icons.space_dashboard_outlined.fontFamily,
                    ),
                  ),
                ), // Icon(Icons.add,color: Primary.primary,),
              ),
            ),
          ),
        );
      },
    );
  }

  photoCircle(Uint8List imageFilePassed, Function func) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: MemoryImage(imageFilePassed),
          ),
        ),
        Positioned(
          top: 20,
          right: 10,
          child: InkWell(
            onTap: () {
              func();
            },
            child: CircleAvatar(
              backgroundColor: Primary.p20,
              radius: 10,
              child: Icon(Icons.close, size: 17, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class MobileDialogRadioButtonsListView extends StatefulWidget {
  const MobileDialogRadioButtonsListView({super.key});

  @override
  State<MobileDialogRadioButtonsListView> createState() =>
      _MobileDialogRadioButtonsListViewState();
}

class _MobileDialogRadioButtonsListViewState
    extends State<MobileDialogRadioButtonsListView> {
  int selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ListTile(
                  title: Text(
                    'serial_number'.tr,
                    style: const TextStyle(fontSize: 12),
                  ),
                  leading: Radio(
                    value: 1,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    'expiry_date'.tr,
                    style: const TextStyle(fontSize: 12),
                  ),
                  leading: Radio(
                    value: 2,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ListTile(
                  title: Text('color'.tr, style: const TextStyle(fontSize: 12)),
                  leading: Radio(
                    value: 3,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('size'.tr, style: const TextStyle(fontSize: 12)),
                  leading: Radio(
                    value: 4,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class MobileDialogCheckBoxesListView extends StatefulWidget {
//   const MobileDialogCheckBoxesListView({super.key});
//
//   @override
//   State<MobileDialogCheckBoxesListView> createState() => _MobileDialogCheckBoxesListViewState();
// }
//
// class _MobileDialogCheckBoxesListViewState extends State<MobileDialogCheckBoxesListView> {
//   bool is1Checked = false;
//   bool is2Checked = false;
//   bool is3Checked = false;
//   bool is4Checked = false;
//   bool is5Checked = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width *0.8,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: ListTile(
//                   title: Text('can_be_sold'.tr,style:const TextStyle(fontSize: 12)),
//                   leading: Checkbox(
//                     // checkColor: Colors.white,
//                     // fillColor: MaterialStateProperty.resolveWith(getColor),
//                     value: is1Checked,
//                     onChanged: (bool? value) {
//                       setState(() {
//                         is1Checked = value!;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: ListTile(
//                   title: Text('can_be_purchased'.tr,style:const TextStyle(fontSize: 12)),
//                   leading: Checkbox(
//                     // checkColor: Colors.white,
//                     // fillColor: MaterialStateProperty.resolveWith(getColor),
//                     value: is2Checked,
//                     onChanged: (bool? value) {
//                       setState(() {
//                         is2Checked = value!;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ],),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: ListTile(
//                   title: Text('warranty'.tr,style:const TextStyle(fontSize: 12)),
//                   leading: Checkbox(
//                     // checkColor: Colors.white,
//                     // fillColor: MaterialStateProperty.resolveWith(getColor),
//                     value: is3Checked,
//                     onChanged: (bool? value) {
//                       setState(() {
//                         is3Checked = value!;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               Expanded(
//                   child:ListTile(
//                     title: Text('discontinued'.tr,style:const TextStyle(fontSize: 12)),
//                     leading: Checkbox(
//                       // checkColor: Colors.white,
//                       // fillColor: MaterialStateProperty.resolveWith(getColor),
//                       value: is4Checked,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           is4Checked = value!;
//                         });
//                       },
//                     ),
//                   )),
//             ],),
//           SizedBox(
//             width: MediaQuery.of(context).size.width *0.4,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Expanded(
//                     child:ListTile(
//                       title: Text('blocked'.tr,style:const TextStyle(fontSize: 12)),
//                       leading: Checkbox(
//                         // checkColor: Colors.white,
//                         // fillColor: MaterialStateProperty.resolveWith(getColor),
//                         value: is5Checked,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             is5Checked = value!;
//                           });
//                         },
//                       ),
//                     )),
//               ],
//             ),
//           ),
//           is4Checked
//               ?DialogDateTextField(
//             textEditingController: dateController,
//             text: 'date'.tr,
//             textFieldWidth:  MediaQuery.of(context).size.width * 0.5,
//             validationFunc: (){},
//             onChangedFunc: (){},
//           )
//               :const SizedBox(),
//         ],
//       ),
//     );
//   }
// }
