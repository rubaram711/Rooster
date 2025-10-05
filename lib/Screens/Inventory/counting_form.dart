import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Screens/Inventory/physical_inventory.dart';
import 'package:rooster_app/Screens/Inventory/print_inventory.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/inventory_controller.dart';
import '../../Controllers/warehouse_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_radio_btns.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../Products/products_page.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class CountingForm extends StatefulWidget {
  const CountingForm({super.key});

  @override
  State<CountingForm> createState() => _CountingFormState();
}

class _CountingFormState extends State<CountingForm> {
  final TextEditingController filterController = TextEditingController();
  bool isGridClicked = false;

  final HomeController homeController = Get.find();
  List tabsList = [
    'form',
    'filter',
  ];
  List<Widget> pagesList = [
    const FormPageOptions(),
    const FilterPage(),
  ];
  int selectedTabIndex = 0;

  WarehouseController warehouseController = Get.find();
  InventoryController inventoryController = Get.find();

  @override
  void initState() {
    warehouseController.getWarehousesFromBack();
    inventoryController.getCategoriesFromBack();
    inventoryController.getAllProductsFromBack();
    inventoryController.getGroupsFromBack();
    inventoryController.dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (inventoryCont) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'counting_form'.tr),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('warehouse'.tr),
                    gapW10,
                    GetBuilder<WarehouseController>(builder: (cont) {
                      return cont.isWarehousesFetched
                          ? DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.15,
                              // requestFocusOnTap: false,
                              enableSearch: true,
                              controller: inventoryCont.warehouseMenuController,
                              hintText: '${'search'.tr}...',
                              inputDecorationTheme: InputDecorationTheme(
                                // filled: true,
                                hintStyle: const TextStyle(
                                    fontStyle: FontStyle.italic),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(20, 0, 25, 5),
                                // outlineBorder: BorderSide(color: Colors.black,),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                                      width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                              ),
                              // menuStyle: ,
                              menuHeight: 250,
                              dropdownMenuEntries: cont.warehousesNameList
                                  .map<DropdownMenuEntry<String>>(
                                      (String option) {
                                return DropdownMenuEntry<String>(
                                  value: option,
                                  label: option,
                                );
                              }).toList(),
                              enableFilter: true,
                              onSelected: (String? val) {
                                var index =
                                    cont.warehousesNameList.indexOf(val!);
                                inventoryCont.setSelectedWarehouseId(
                                    '${cont.warehouseIdsList[index]}');
                              },
                            )
                          : loading();
                    }),
                  ],
                ),
                gapW40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('date'.tr),
                    gapW10,
                    DialogDateTextField(
                      textEditingController: inventoryCont.dateController,
                      text: '',
                      textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                      validationFunc: (val) {},
                      onChangedFunc: (value) {
                        //dateController.text = value;
                      },
                      onDateSelected: (value) {
                        String rd =
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                        DateTime dt1 = DateTime.parse("$rd 00:00:00");
                        DateTime dt2 = DateTime.parse("$value 00:00:00");
                        if (dt2.isBefore(dt1) || dt2.isAtSameMomentAs(dt1)) {
                          inventoryCont.dateController.text = value;
                        } else {
                          CommonWidgets.snackBar(
                              'error', 'date can\'t be after today');
                        }
                      },
                    ),
                  ],
                ),
                gapW40,
                ReusableButtonWithColor(
                  btnText: 'Go',
                  onTapFunction: () async {
                    // await inventoryCont.getInventoryDataFromBack();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return   const PrintInventory(
                           // items: inventoryCont.itemsList,
                          );
                        }));
                  },
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                gapW24,
                TextButton(
                    onPressed: (){
                      inventoryCont.inventoryData = [];
                      inventoryCont.selectedWarehouseId = '';
                      inventoryCont.warehouseMenuController.clear();
                      inventoryCont.selectedCategoryId = '0';
                      inventoryCont.selectedCategoriesIdsList = [];
                      inventoryCont.categoryController.text='all_categories'.tr;
                      inventoryCont.itemsController.text='all_items'.tr;
                      inventoryCont.selectedItemId = '0';
                      inventoryCont.getGroupsFromBack();
                      inventoryCont.dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      inventoryCont.isPrintWithQtyChecked = true;
                      inventoryCont.selectedValueForPackaging = 1;
                    },
                    child: Text('discard'.tr,style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Primary.primary
                    ),)),

              ],
            ),
            gapH20,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children: tabsList
                        .map((element) => ReusableBuildTabChipItem(
                              name: element,
                              index: tabsList.indexOf(element),
                              function: () {
                                setState(() {
                                  selectedTabIndex = tabsList.indexOf(element);
                                });
                              },
                              isClicked:
                                  selectedTabIndex == tabsList.indexOf(element),
                            ))
                        .toList()),
              ],
            ),
            gapH20,
            pagesList[selectedTabIndex]
          ],
        ),
      );
    });
  }
}

class FormPageOptions extends StatefulWidget {
  const FormPageOptions({super.key});

  @override
  State<FormPageOptions> createState() => _FormPageOptionsState();
}

class _FormPageOptionsState extends State<FormPageOptions> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (cont) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  // checkColor: Colors.white,
                  // fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: cont.isPrintWithQtyChecked,
                  onChanged: (bool? value) {
                      cont.setIsPrintWithQtyChecked(value!);
                  },
                ),
                gapW4,
                Text('print_qty'.tr, style: const TextStyle(fontSize: 12)),
              ],
            ),
            gapH20,
            Text('  Extra Column'.tr,),
            Container(
              // width: MediaQuery.of(context).size.width * 0.25,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child:   ReusableRadioBtns(
                isRow: false,
                groupVal: cont.selectedValueForPackaging,
                title1: 'Print Item Packaging',
                title2: 'Print item unit name',
                func: (value) {
                  cont.setSelectedValue(value!);
                },
                width1: MediaQuery.of(context).size.width ,
                width2: MediaQuery.of(context).size.width ,
              ),
            ),

          ],
        );
      }
    );
  }
}


class MobileCountingForm extends StatefulWidget {
  const MobileCountingForm({super.key});

  @override
  State<MobileCountingForm> createState() => _MobileCountingFormState();
}

class _MobileCountingFormState extends State<MobileCountingForm> {
  final TextEditingController filterController = TextEditingController();
  FilterItems? selectedFilterItem;
  // GlobalKey filterKey = GlobalKey();
  bool isGridClicked = false;

  final HomeController homeController = Get.find();
  List tabsList = [
    'form',
    'filter',
  ];
  List<Widget> pagesList = [
    const FormPageOptions(),
    const FilterPage(isMobile: true,),
  ];
  int selectedTabIndex = 0;

  WarehouseController warehouseController = Get.find();
  InventoryController inventoryController = Get.find();

  @override
  void initState() {
    warehouseController.getWarehousesFromBack();
    inventoryController.getCategoriesFromBack();
    inventoryController.getAllProductsFromBack();
    inventoryController.getGroupsFromBack();
    inventoryController.dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(builder: (inventoryCont) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02),
        // height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(text: 'counting_form'.tr),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('warehouse'.tr),
                gapW10,
                GetBuilder<WarehouseController>(builder: (cont) {
                  return cont.isWarehousesFetched
                      ? DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width * 0.5,
                    // requestFocusOnTap: false,
                    enableSearch: true,
                    controller: inventoryCont.warehouseMenuController,
                    hintText: '${'search'.tr}...',
                    inputDecorationTheme: InputDecorationTheme(
                      // filled: true,
                      hintStyle: const TextStyle(
                          fontStyle: FontStyle.italic),
                      contentPadding:
                      const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      // outlineBorder: BorderSide(color: Colors.black,),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                            width: 1),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                            width: 2),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(9)),
                      ),
                    ),
                    // menuStyle: ,
                    menuHeight: 250,
                    dropdownMenuEntries: cont.warehousesNameList
                        .map<DropdownMenuEntry<String>>(
                            (String option) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                          );
                        }).toList(),
                    enableFilter: true,
                    onSelected: (String? val) {
                      var index =
                      cont.warehousesNameList.indexOf(val!);
                      inventoryCont.setSelectedWarehouseId(
                          '${cont.warehouseIdsList[index]}');
                    },
                  )
                      : loading();
                }),
              ],
            ),
            gapH10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('date'.tr),
                gapW10,
                DialogDateTextField(
                  textEditingController: inventoryCont.dateController,
                  text: '',
                  textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                  validationFunc: (val) {},
                  onChangedFunc: (value) {
                    //dateController.text = value;
                  },
                  onDateSelected: (value) {
                    String rd =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                    DateTime dt1 = DateTime.parse("$rd 00:00:00");
                    DateTime dt2 = DateTime.parse("$value 00:00:00");
                    if (dt2.isBefore(dt1) || dt2.isAtSameMomentAs(dt1)) {
                      inventoryCont.dateController.text = value;
                    } else {
                      CommonWidgets.snackBar(
                          'error', 'date can\'t be after today');
                    }
                  },
                ),
              ],
            ),
            gapH10,
            Row(
              children: [
                ReusableButtonWithColor(
                  btnText: 'Go',
                  onTapFunction: () async {
                    // await inventoryCont.getInventoryDataFromBack();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return   const PrintInventory(isMobile: true,
                            // items: inventoryCont.itemsList,
                          );
                        }));
                  },
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.25,
                ),
                gapW24,
                TextButton(
                    onPressed: (){
                      inventoryCont.inventoryData = [];
                      inventoryCont.selectedWarehouseId = '';
                      inventoryCont.warehouseMenuController.clear();
                      inventoryCont.selectedCategoryId = '0';
                      inventoryCont.selectedCategoriesIdsList = [];
                      inventoryCont.categoryController.text='all_categories'.tr;
                      inventoryCont.itemsController.text='all_items'.tr;
                      inventoryCont.selectedItemId = '0';
                      inventoryCont.getGroupsFromBack();
                      inventoryCont.dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      inventoryCont.isPrintWithQtyChecked = true;
                      inventoryCont.selectedValueForPackaging = 1;
                    },
                    child: Text('discard'.tr,style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Primary.primary
                    ),)),
              ],
            ),
            gapH20,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children: tabsList
                        .map((element) => ReusableBuildTabChipItem(
                      name: element,
                      index: tabsList.indexOf(element),
                      function: () {
                        setState(() {
                          selectedTabIndex = tabsList.indexOf(element);
                        });
                      },
                      isClicked:
                      selectedTabIndex == tabsList.indexOf(element),
                    ))
                        .toList()),
              ],
            ),
            gapH20,
            pagesList[selectedTabIndex]
          ],
        ),
      );
    });
  }
}