import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/GarageBackend/BrandsBackend/store_brand.dart';
import 'package:rooster_app/Backend/GarageBackend/BrandsBackend/update_brand.dart';
import 'package:rooster_app/Backend/GarageBackend/ModelsBackend/store_model.dart';
import 'package:rooster_app/Backend/GarageBackend/ModelsBackend/update_model.dart';
import 'package:rooster_app/Backend/GarageBackend/TechniciansBackend/store_technician.dart';
import 'package:rooster_app/Backend/GarageBackend/TechniciansBackend/update_technician.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import '../../../Widgets/dialog_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/GarageBackend/ColorsBackend/store_color.dart';
import '../../Backend/GarageBackend/ColorsBackend/update_color.dart';
import '../../Controllers/garage_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/reusable_drop_down_menu.dart';

class AddGarageAttributeDialog extends StatefulWidget {
  const AddGarageAttributeDialog({super.key, this.text, this.id, this.brand});
  final String? text;
  final String? id;
  final Map? brand;
  @override
  State<AddGarageAttributeDialog> createState() => _AddGarageAttributeDialogState();
}

class _AddGarageAttributeDialogState extends State<AddGarageAttributeDialog> {
  TextEditingController textController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  HomeController homeController = Get.find();
  GarageController garageController = Get.find();

  @override
  void initState() {
    if(widget.text!=null) {
      textController.text = widget.text!;
    }
    if(garageController.selectedAttributeText=='model'){
      garageController.getAllBrandsFromBack();
      if(widget.brand!=null) {
        garageController.selectedBrandId = '${widget.brand!['id']}';
        brandController.text = '${widget.brand!['name']}';
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GarageController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          // width: Sizes.deviceWidth*0.2,
          height:garageController.selectedAttributeText=='model'?300: 250,
          // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTitle(
                    text:
                    garageController.selectedAttributeText == 'color'
                            ? 'add_new_color'.tr
                            : garageController.selectedAttributeText == 'model'
                            ? 'add_new_model'.tr
                            : garageController.selectedAttributeText == 'technician'
                            ? 'add_new_technician'.tr
                            : 'add_new_brand'.tr,
                  ),
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
              gapH40,
              garageController.selectedAttributeText == 'model' && !garageController.isItUpdateAttribute?ReusableDropDownMenuWithSearch(
              list: cont.carBrandsNames,
              text: 'brand'.tr,
              hint: '${'search'.tr}...',
              controller: brandController,
              onSelected: (String? val) {
                var ind=cont.carBrandsNames.indexOf(val!);
                cont.updateSelectedCarBrand(cont.carBrandsIds[ind]);
              },
              validationFunc: (value) {
                if (value == null || value.isEmpty) {
                  return 'select_option'.tr;
                }
                return null;
              },
              textFieldWidth:
              homeController.isMobile.value
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.15,
              rowWidth:
              homeController.isMobile.value
                  ? MediaQuery.of(context).size.width * 0.55
                  : MediaQuery.of(context).size.width * 0.25,
              clickableOptionText:
              'create_new_brand'.tr,
              isThereClickableOption: true,
              onTappedClickableOption: () {
                garageController.setSelectedAttributeText( 'brand');
                garageController.setIsItUpdateAttribute( false);
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
            ):SizedBox(),
              gapH10,
              DialogTextField(
                textEditingController: textController,
                textFieldWidth:
                    homeController.isMobile.value
                        ? MediaQuery.of(context).size.width * 0.3
                        : MediaQuery.of(context).size.width * 0.15,
                rowWidth:
                    homeController.isMobile.value
                        ? MediaQuery.of(context).size.width * 0.55
                        : MediaQuery.of(context).size.width * 0.25,
                validationFunc: (val) {},
                text: '${garageController.selectedAttributeText.tr}*',
              ),
              gapH32,
              ReusableButtonWithColor(
                btnText: 'save'.tr,
                radius: 9,
                onTapFunction: () async {
                  if (textController.text.isNotEmpty) {
                    // ignore: prefer_typing_uninitialized_variables
                    var res;
                    if (garageController.selectedAttributeText == 'color') {
                      if(garageController.isItUpdateAttribute)
                      {
                        res = await editColor(widget.id!,textController.text);
                      }
                      else{
                        res = await addColor(textController.text);
                      }
                    }
                    if (garageController.selectedAttributeText == 'brand') {
                      if(garageController.isItUpdateAttribute)
                      {
                        res = await editBrand(widget.id!,textController.text);
                      }
                      else{
                        res = await addBrand(textController.text);
                      }
                    }
                    if (garageController.selectedAttributeText == 'model') {
                      if(garageController.isItUpdateAttribute)
                      {
                        res = await editModel(widget.id!,textController.text);
                      }
                      else{
                        res = await addModel(textController.text,cont.selectedBrandId);
                      }
                    }else{
                      if(garageController.isItUpdateAttribute)
                      {
                        res = await editTechnician(widget.id!,textController.text);
                      }
                      else{
                        res = await addTechnician(textController.text);
                      }
                    }
                    Get.back();
                    if ('${res['success']}' == 'true') {
                      garageController.getAllAttributesFromBack();
                      CommonWidgets.snackBar('Success', res['message']);
                    } else {
                      CommonWidgets.snackBar('error', res['message']);
                    }
                  } else {
                    CommonWidgets.snackBar('error', 'name is required');
                  }
                },
                width: MediaQuery.of(context).size.width * 0.25,
                height: 50,
              ),
            ],
          ),
        );
      }
    );
  }
}
