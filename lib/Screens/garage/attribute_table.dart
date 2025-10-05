import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/GarageBackend/BrandsBackend/delete_brand.dart';
import 'package:rooster_app/Backend/GarageBackend/ModelsBackend/delete_model.dart';
import 'package:rooster_app/Backend/GarageBackend/TechniciansBackend/delete_technician.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/const/colors.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../Widgets/table_item.dart';
import '../../../Widgets/table_title.dart';
import '../../../const/Sizes.dart';
import '../../Backend/GarageBackend/ColorsBackend/delete_color.dart';
import '../../Controllers/garage_controller.dart';
import '../../Widgets/loading.dart';
import 'add_attribute.dart';


class AttributeTablePage extends StatefulWidget {
  const AttributeTablePage({super.key});

  @override
  State<AttributeTablePage> createState() => _AttributeTablePageState();
}

class _AttributeTablePageState extends State<AttributeTablePage> {
  GarageController garageController = Get.find();
  HomeController homeController = Get.find();
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
        800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
            () => searchOnStoppedTyping = Timer(duration, () => search(value)));
  }

  search(value) async {
    garageController.getAllAttributesFromBack();
  }
  @override
  void initState() {
    garageController.getAllAttributesFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05:MediaQuery.of(context).size.width * 0.02),
      child: GetBuilder<GarageController>(
          builder: (cont) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(text: cont.selectedAttributeText.tr),
                      ReusableButtonWithColor(
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                        height: 45,
                        onTapFunction: () {
                          cont.setIsItUpdateAttribute(false);
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                                ),
                                elevation: 0,
                                content:AddGarageAttributeDialog(),
                                // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
                              ));
                        },
                        btnText:   cont.selectedAttributeText == 'color'
                            ? 'add_new_color'.tr
                            : cont.selectedAttributeText == 'model'
                            ? 'add_new_model'.tr
                            : cont.selectedAttributeText == 'technician'
                            ? 'add_new_technician'.tr
                            : 'add_new_brand'.tr,
                      ),
                    ],
                  ),
                  gapH16,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        // width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.9: MediaQuery.of(context).size.width * 0.7,
                        child: ReusableSearchTextField(
                          hint: '${"search".tr}...',
                          textEditingController: cont.searchOnAttributeValueController,
                          onChangedFunc: (val) {
                            _onChangeHandler(val);
                          },
                          validationFunc: (val) {},
                        ),
                      ),
                    ],
                  ),
                  gapH32,
                  cont.isAttributesFetched
                      ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: homeController.isMobile.value ?MediaQuery.of(context).size.width :
                        garageController.selectedAttributeText=='model'?
                        MediaQuery.of(context).size.width * 0.52:MediaQuery.of(context).size.width * 0.32,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width * 0.01,
                            vertical: 15),
                        decoration: BoxDecoration(
                            color: Primary.primary,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(6))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TableTitle(
                              text: 'name'.tr,
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5: MediaQuery.of(context).size.width * 0.2,
                            ),
                            garageController.selectedAttributeText=='model'?TableTitle(
                              text: 'brand'.tr,
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5: MediaQuery.of(context).size.width * 0.2,
                            ):SizedBox(),
                            // TableTitle(
                            //   text: 'sub_categories'.tr,
                            //   width: MediaQuery.of(context).size.width * 0.15,
                            // ),
                            SizedBox(
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                            ),
                            SizedBox(
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height:homeController.isMobile.value ? MediaQuery.of(context).size.height * 0.57:MediaQuery.of(context).size.height * 0.5,
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width :garageController.selectedAttributeText=='model'?
                        MediaQuery.of(context).size.width * 0.52: MediaQuery.of(context).size.width * 0.32,
                        child: ListView.builder(
                          itemCount: cont.attributeValuesList.length,
                          itemBuilder: (context, index) =>
                              _attributeAsRowInTable(
                                cont.attributeValuesList[index] ,
                                index,
                              ),
                        ),
                      ),
                    ],
                  )
                      : Center(child: loading()),
                ],
              ),
            );
          }
      ),
    );
  }

  _attributeAsRowInTable(Map info, int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: info['name'] ?? '',
            width: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5:MediaQuery.of(context).size.width * 0.2,
          ),
          garageController.selectedAttributeText=='model'?TableItem(
            text: info['brand']['name'] ?? '',
            width: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5:MediaQuery.of(context).size.width * 0.2,
          ):SizedBox(),
          Row(
            children: [
              SizedBox(
                width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    garageController.setIsItUpdateAttribute(true);
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(9)),
                          ),
                          elevation: 0,
                          content:AddGarageAttributeDialog(text:  info['name'],id: '${info['id']}',
                           brand:  garageController.selectedAttributeText=='model'?info['brand']:null
                          ),
                          // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
                        ));
                  },
                  child: Icon(
                    Icons.mode_edit_outlined,
                    color: Primary.primary,
                  ),
                ),
              ),
              SizedBox(
                width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    var res ;
                    if(garageController.selectedAttributeText=='color'){
                      res = await deleteColor(
                          '${info['id']}');
                    }
                    else if(garageController.selectedAttributeText=='brand'){
                      res = await deleteBrand(
                          '${info['id']}');
                    }
                    else if(garageController.selectedAttributeText=='model'){
                      res = await deleteModel(
                          '${info['id']}');
                    }else{
                      res = await deleteTechnician(
                          '${info['id']}');
                    }
                    if (res.statusCode == 200) {
                      garageController.getAllAttributesFromBack();
                      CommonWidgets.snackBar('Success',
                          res['message']);
                    } else {
                      CommonWidgets.snackBar(
                          'error',   res['message']);
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
        ],
      ),
    );
  }
}

