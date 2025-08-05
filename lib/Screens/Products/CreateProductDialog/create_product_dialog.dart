import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/pos_tab_content.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/pricing_tab_content.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/procurement_tab_content.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/quantities_tab_content.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/shelving_tab_content.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/shipping_tab_content.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Controllers/products_controller.dart';
import '../../../Widgets/dialog_title.dart';
import '../../../Widgets/reusable_btns_row.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import 'alt_code_tab_content.dart';
import 'general_tab_content.dart';
import 'grouping_tab_content.dart';
// import 'dart:io';

List tabsList = [
  'general',
  'alt_codes',
  'grouping',
  'procurement',
  'pricing',
  'quantities',
  'shelving',
  'shipping',
  'pos'
];

List tabsListForMobile = [
  'general',
  // 'alt_codes',
  // 'grouping',
  // 'procurement',
  'pricing',
  'quantities',
  // 'shelving',
  // 'shipping',
  'pos'
];

List tabsContent = [
  GeneralTabContent(),
  const AltCodeTabContent(),
  const GroupingTabContent(),
  const ProcurementTabContent(),
  const PricingTabContent(),
  const QuantitiesTabContent(),
  const ShelvingTabContent(isDesktop: true),
  const ShippingTabContent(isDesktop: true),
  const PosTabContent(isDesktop: true),
];

List mobileTabsContent = [
  MobileGeneralTabContent(),
  // const MobileAltCodeTabContent(),
  // const GroupingTabContent(),
  // const MobileProcurementTabContent(),
  const MobilePricingTabContent(),
  const MobileQuantitiesTabContent(),
  // const ShelvingTabContent(isDesktop: false),
  // const ShippingTabContent(isDesktop: false),
  const PosTabContent(isDesktop: false),
];

class CreateProductDialogContent extends StatefulWidget {
  const CreateProductDialogContent({super.key, this.isFromProductsPage=false,});
  final bool isFromProductsPage;
  @override
  State<CreateProductDialogContent> createState() =>
      _CreateProductDialogContentState();
}

class _CreateProductDialogContentState
    extends State<CreateProductDialogContent> {
  final HomeController homeController = Get.find();
  final ProductController productController = Get.find();
  @override
  void initState() {
    productController.isProductsPageIsLastPage=widget.isFromProductsPage;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (cont) {
      return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.95,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DialogTitle(
                    text: cont.isItUpdateProduct
                        ? 'update_product'.tr
                        : 'create_new_product'.tr),
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
            gapH10,
            Wrap(
                spacing: 0.01,
                direction: Axis.horizontal,
                children: tabsList
                    .map((element) => _buildTabChipItem(
                        element,
                        // element['id'],
                        // element['name'],
                        tabsList.indexOf(element)))
                    .toList()),
            // gapH28,
            tabsContent[cont.selectedTabIndex],
            ReusableBTNsRow(
              onBackClicked: () {
                cont.setSelectedTabIndex(6);
              },
              onDiscardClicked: () {
                cont.discardShipping();
                // packageController.clear();
                // defaultTransactionPackageController.clear();
                packageController.text = cont.packagesNames[
                cont.packagesIds
                    .indexOf(cont.selectedPackageId)];
                defaultTransactionPackageController.text =
                cont.packagesNames[cont
                    .packagesIds
                    .indexOf(cont.selectedPackageId)];
              },
              onNextClicked: () {
                // if (_formKey.currentState!.validate()) {
                cont.setSelectedTabIndex(8);
                // }
              },
              onSaveClicked: () {},
            )
          ],
        ),
      );
    });
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<ProductController>(builder: (cont) {
      return InkWell(
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
          child: Container(
             width: MediaQuery.of(context).size.width * 0.09,
            height: MediaQuery.of(context).size.height * 0.05,
            decoration: BoxDecoration(
                color:
                    cont.selectedTabIndex == index ? Primary.p20 : Colors.white,
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
    });
  }
}




class MobileCreateProductDialogContent extends StatefulWidget {
  const MobileCreateProductDialogContent({super.key});

  @override
  State<MobileCreateProductDialogContent> createState() =>
      _MobileCreateProductDialogContentState();
}

class _MobileCreateProductDialogContentState
    extends State<MobileCreateProductDialogContent> {
  // int selectedTabIndex = 0;
  final HomeController homeController = Get.find();
  final ProductController productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (cont) {
      return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width ,
        height: MediaQuery.of(context).size.height * 0.9,
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01,
            vertical: MediaQuery.of(context).size.width * 0.02),
        // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(
                      text: cont.isItUpdateProduct
                          ? 'update_product'.tr
                          : 'create_new_product'.tr),
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
              Wrap(
                  spacing: 0.0,
                  direction: Axis.horizontal,
                  children: tabsListForMobile
                      .map((element) => _buildTabChipItem(
                          element,
                          // element['id'],
                          // element['name'],
                      tabsListForMobile.indexOf(element)))
                      .toList()),
              gapH10,
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child:mobileTabsContent[cont.selectedTabIndex],
              ),
              // const Spacer(),
              ReusableBTNsRow(
                onBackClicked: () {
                  cont.setSelectedTabIndex(6);
                },
                onDiscardClicked: () {
                  cont.discardShipping();
                  // packageController.clear();
                  // defaultTransactionPackageController.clear();
                  packageController.text = cont.packagesNames[
                  cont.packagesIds
                      .indexOf(cont.selectedPackageId)];
                  defaultTransactionPackageController.text =
                  cont.packagesNames[cont
                      .packagesIds
                      .indexOf(cont.selectedPackageId)];
                },
                onNextClicked: () {
                  // if (_formKey.currentState!.validate()) {
                    cont.setSelectedTabIndex(8);
                  // }
                },
                onSaveClicked: () {},
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<ProductController>(builder: (cont) {
      return InkWell(
        onTap: () {
          cont.setSelectedTabIndex(index);
        },
        child: ClipPath(
          clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9)))),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.22,
            height: MediaQuery.of(context).size.height * 0.07,
            // padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            decoration: BoxDecoration(
                color:
                    cont.selectedTabIndex == index ? Primary.p20 : Colors.white,
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
    });
  }
}


