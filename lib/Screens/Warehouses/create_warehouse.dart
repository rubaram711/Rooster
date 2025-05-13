
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/warehouse_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/ConfigurationsBackend/Warehouses/create_warehouse.dart';
import '../../Controllers/home_controller.dart';

import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_text_field.dart';

class CreateWarehousePage extends StatefulWidget {
  const CreateWarehousePage({super.key});

  @override
  State<CreateWarehousePage> createState() => _CreateWarehousePageState();
}

class _CreateWarehousePageState extends State<CreateWarehousePage> {
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
      height:homeController.isMobile.value? MediaQuery.of(context).size.height * 0.6: MediaQuery.of(context).size.height * 0.8,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'create_warehouse'.tr),
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
                          homeController.selectedTab.value='warehouses';
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