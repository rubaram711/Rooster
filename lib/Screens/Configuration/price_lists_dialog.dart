import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/PriceListBackend/delete_price_list.dart';
import 'package:rooster_app/Backend/PriceListBackend/store_price_list.dart';
import 'package:rooster_app/Backend/PriceListBackend/update_price_list.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/price_list_controller.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/custom_snak_bar.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/loading_dialog.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_radio_btns.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';

class PriceListDialogContent extends StatefulWidget {
  const PriceListDialogContent({super.key});

  @override
  State<PriceListDialogContent> createState() => _PriceListDialogContentState();
}

class _PriceListDialogContentState extends State<PriceListDialogContent> {
  PriceListController priceListController = Get.find();
  List tabsList = [
    'general',
    'properties',
    // 'items', 'clients'
  ];

  List tabsContent = [
    const GeneralTabInPriceLists(),
    const PropertiesTabInPriceLists(),
    // const ItemsTabInPriceLists(),
    // const ClientsTabInPriceLists(),
  ];
  @override
  void initState() {
    priceListController.getAllPricesListFromBack();
    priceListController.getCategoriesFromBack();
    priceListController.getAllProductsFromBack();
    priceListController.getGroupsFromBack();
    priceListController.codeController.clear();
    priceListController.nameController.clear();
    priceListController.initialValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(text: 'price_lists'.tr),
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
              gapH24,
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
                                name: element,
                                index: tabsList.indexOf(element),
                                function: () {
                                  cont.setSelectedTabIndex(
                                    tabsList.indexOf(element),
                                  );
                                },
                                isClicked:
                                    cont.selectedTabIndex ==
                                    tabsList.indexOf(element),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              tabsContent[cont.selectedTabIndex],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        priceListController.resetValues();
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
                      if (priceListController.nameController.text.isEmpty) {
                        CommonWidgets.snackBar('error', 'Name is Required');
                      } else if (priceListController
                          .codeController
                          .text
                          .isEmpty) {
                        CommonWidgets.snackBar('error', 'Code is Required');
                      } else {
                        if (cont.adjustmentPercentageController.text == '0') {
                          showDialog<String>(
                            // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                                  ),
                                  elevation: 0,
                                  content: ZeroChangeDialog()));
                        } else {
                          showDialog<String>(
                            context: context,
                            builder:
                                (BuildContext context) => const AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(9),
                                    ),
                                  ),
                                  elevation: 0,
                                  content: LoadingDialog(
                                    text: 'This Process Takes Some Time...',
                                  ),
                                ),
                          );
                          if (cont.selectedPriceListIdForUpdate == '') {
                            var p = await storePriceList(
                              title: priceListController.nameController.text,
                              code: priceListController.codeController.text,
                              vatInclusivePrices:
                                  priceListController
                                          .isVatInclusivePricesChecked
                                      ? '1'
                                      : '0',
                              derivedPrices:
                                  priceListController.isDerivedPricesChecked
                                      ? '1'
                                      : '0',
                              pricelistId:
                                  priceListController
                                      .selectedAnotherPriceListId,
                              type: 'percentage',
                              adjustmentPercentage:
                                  priceListController.selectedMethod ==
                                              'MINUS' &&
                                          priceListController
                                                  .adjustmentPercentageController
                                                  .text !=
                                              '0'
                                      ? '-${priceListController.adjustmentPercentageController.text}'
                                      : priceListController
                                          .adjustmentPercentageController
                                          .text,
                              convertToCurrencyId:
                                  priceListController.selectedCurrencyId,
                              roundingMethod:
                                  priceListController.selectedRoundingMethod,
                              roundingPrecision:
                                  priceListController.roundValueController.text,
                              transactionDisplayMode:
                                  priceListController
                                              .selectedDisplayModeRadio ==
                                          1
                                      ? 'net'
                                      : 'visible_discount',
                              categories:
                                  priceListController.selectedCategoriesIdsList,
                              itemGroups: priceListController.selectedGroupsIds,
                              singleItemId: priceListController.selectedItemId,
                            );
                            Get.back();
                            if (p['success'] == true) {
                              CommonWidgets.snackBar('Success', p['message']);
                              cont.setSelectedTabIndex(0);
                              priceListController.resetValues();
                              cont.getAllPricesListFromBack();
                            } else {
                              CommonWidgets.snackBar('error', p['message']);
                            }
                          } else {
                            var p = await updatePriceList(
                              priceListId: cont.selectedPriceListIdForUpdate,
                              title: priceListController.nameController.text,
                              code: priceListController.codeController.text,
                              vatInclusivePrices:
                                  priceListController
                                          .isVatInclusivePricesChecked
                                      ? '1'
                                      : '0',
                              derivedPrices:
                                  priceListController.isDerivedPricesChecked
                                      ? '1'
                                      : '0',
                              pricelistId:
                                  priceListController
                                      .selectedAnotherPriceListId,
                              type: 'percentage',
                              adjustmentPercentage:
                                  priceListController.selectedMethod == 'MINUS'
                                      ? '-${priceListController.adjustmentPercentageController.text}'
                                      : priceListController
                                          .adjustmentPercentageController
                                          .text,
                              convertToCurrencyId:
                                  priceListController.selectedCurrencyId,
                              roundingMethod:
                                  priceListController.selectedRoundingMethod,
                              roundingPrecision:
                                  priceListController.roundValueController.text,
                              transactionDisplayMode:
                                  priceListController
                                              .selectedDisplayModeRadio ==
                                          1
                                      ? 'net'
                                      : 'visible_discount',
                              categories:
                                  priceListController.selectedCategoriesIdsList,
                              itemGroups: priceListController.selectedGroupsIds,
                              singleItemId: priceListController.selectedItemId,
                            );
                            Get.back();
                            if (p['success'] == true) {
                              CommonWidgets.snackBar('Success', p['message']);
                              cont.setSelectedTabIndex(0);
                              priceListController.resetValues();
                              cont.getAllPricesListFromBack();
                            } else {
                              CommonWidgets.snackBar('error', p['message']);
                            }
                          }
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

class GeneralTabInPriceLists extends StatefulWidget {
  const GeneralTabInPriceLists({super.key});

  @override
  State<GeneralTabInPriceLists> createState() => _GeneralTabInPriceListsState();
}

class _GeneralTabInPriceListsState extends State<GeneralTabInPriceLists> {
  PriceListController priceListController = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                color: Primary.primary,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TableTitle(
                    isCentered: false,
                    text: 'code'.tr,
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                  TableTitle(
                    isCentered: false,
                    text: 'name'.tr,
                    width: MediaQuery.of(context).size.width * 0.15,
                  ),
                ],
              ),
            ),
            cont.isAddNewPriceListClicked
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Primary.p10,
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DialogTextField(
                          validationFunc: (String value) {
                            if (value.isEmpty) {
                              return 'required_field'.tr;
                            }
                            return null;
                          },
                          text: '',
                          rowWidth: MediaQuery.of(context).size.width * 0.1,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.09,
                          textEditingController: cont.codeController,
                        ),
                        DialogTextField(
                          validationFunc: (String value) {
                            if (value.isEmpty) {
                              return 'required_field'.tr;
                            }
                            return null;
                          },
                          text: '',
                          rowWidth: MediaQuery.of(context).size.width * 0.15,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.14,
                          textEditingController: cont.nameController,
                        ),
                      ],
                    ),
                  ),
                )
                : const SizedBox(),
            cont.isPricesListFetched
                ? Container(
                  color: Colors.white,
                  height:
                      cont.priceLists.length < 6
                          ? cont.priceLists.length * 55
                          : MediaQuery.of(context).size.height * 0.48,
                  child: ListView.builder(
                    itemCount:
                        cont.priceLists.length, //products is data from back res
                    itemBuilder:
                        (context, index) => priceListAsRowInTable(
                          cont.priceLists[index],
                          index,
                        ),
                  ),
                )
                : loading(),
            gapH10,
            cont.isAddNewPriceListClicked ||
                    cont.selectedPriceListIdForUpdate != ''
                ? const SizedBox()
                : ReusableAddCard(
                  text: 'new_price_list'.tr,
                  onTap: () {
                    cont.resetValues();
                    cont.setIsAddNewPriceListClicked(true);
                  },
                ),
          ],
        );
      },
    );
  }

  priceListAsRowInTable(Map info, int index) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return InkWell(
          onTap: () {
            cont.setValues(info);
            // cont.setSelectedPriceListForUpdate('${info['id']}');
            cont.setSelectedPriceListObjectForUpdate(info);
            // cont.setIsAddNewPriceListClicked(false);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  '${info['id']}' == cont.selectedPriceListIdForUpdate
                      ? 10
                      : 40,
              vertical:
                  '${info['id']}' == cont.selectedPriceListIdForUpdate ? 2 : 10,
            ),
            decoration: BoxDecoration(
              color:
                  '${info['id']}' == cont.selectedPriceListIdForUpdate
                      ? Primary.p10
                      : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0)),
            ),
            child:
                '${info['id']}' == cont.selectedPriceListIdForUpdate
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DialogTextField(
                          validationFunc: (String value) {
                            if (value.isEmpty) {
                              return 'required_field'.tr;
                            }
                            return null;
                          },
                          text: '',
                          rowWidth: MediaQuery.of(context).size.width * 0.1,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.09,
                          textEditingController: cont.codeController,
                        ),
                        DialogTextField(
                          validationFunc: (String value) {
                            if (value.isEmpty) {
                              return 'required_field'.tr;
                            }
                            return null;
                          },
                          text: '',
                          rowWidth: MediaQuery.of(context).size.width * 0.15,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.14,
                          textEditingController: cont.nameController,
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TableItem(
                              isCentered: false,
                              text: '${info['code'] ?? ''}',
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),
                            TableItem(
                              isCentered: false,
                              text: '${info['title'] ?? ''}',
                              width: MediaQuery.of(context).size.width * 0.15,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                          child: InkWell(
                            onTap: () async {
                              var res = await deletePriceList('${info['id']}');
                              var p = json.decode(res.body);
                              if (res.statusCode == 200) {
                                CommonWidgets.snackBar('Success', p['message']);
                                priceListController.resetValues();
                                priceListController.getAllPricesListFromBack();
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
      },
    );
  }
}

class ItemsTabInPriceLists extends StatefulWidget {
  const ItemsTabInPriceLists({super.key});

  @override
  State<ItemsTabInPriceLists> createState() => _ItemsTabInPriceListsState();
}

class _ItemsTabInPriceListsState extends State<ItemsTabInPriceLists> {
  List groupsList = [
    {
      'code': '22MP410',
      'name': 'LG MONITOR, HDMI FHDLG MONITOR, HDMI FHD',
      'currency': 'USD',
      'saleprice': '0.00',
      'discount': '0.00%',
      'price_dicounted': '0.00',
    },
    {
      'code': '3000N',
      'name': 'LG MONITOR, HDMI FHDLG MONITOR, HDMI FHD',
      'currency': 'LBP',
      'saleprice': '0.00',
      'discount': '0.00%',
      'price_dicounted': '0.00',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
            color: Primary.primary,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TableTitle(
                text: 'code'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'name'.tr,
                width: MediaQuery.of(context).size.width * 0.3,
              ),
              TableTitle(
                text: 'currency'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'saleprice'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'discount'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: '${'discount'.tr} %',
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'price_dicounted'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView.builder(
            itemCount: groupsList.length, //products is data from back res
            itemBuilder:
                (context, index) => groupAsRowInTable(
                  groupsList[index],
                  index,
                  groupsList.length,
                ),
          ),
        ),
        ReusableAddCard(text: 'new_item'.tr, onTap: () {}),
      ],
    );
  }

  groupAsRowInTable(Map altCode, int index, int altCodesListLength) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        color: (index % 2 == 0) ? Primary.p10 : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: '${altCode['code'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['name'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          TableItem(
            text: '${altCode['currency'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['saleprice'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['discount'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['discount'] ?? ''}%',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['price_dicounted'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
        ],
      ),
    );
  }
}

class ClientsTabInPriceLists extends StatefulWidget {
  const ClientsTabInPriceLists({super.key});

  @override
  State<ClientsTabInPriceLists> createState() => _ClientsTabInPriceListsState();
}

class _ClientsTabInPriceListsState extends State<ClientsTabInPriceLists> {
  List groupsList = [
    {
      'code': '22MP410',
      'name': 'LG MONITOR, HDMI FHDLG MONITOR, HDMI FHD',
      'currency': 'USD',
      'saleprice': '0.00',
      'discount': '0.00%',
      'price_dicounted': '0.00',
    },
    {
      'code': '3000N',
      'name': 'LG MONITOR, HDMI FHDLG MONITOR, HDMI FHD',
      'currency': 'LBP',
      'saleprice': '0.00',
      'discount': '0.00%',
      'price_dicounted': '0.00',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
            color: Primary.primary,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TableTitle(
                text: 'code'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'name'.tr,
                width: MediaQuery.of(context).size.width * 0.3,
              ),
              TableTitle(
                text: 'currency'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'saleprice'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'discount'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: '${'discount'.tr} %',
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'price_dicounted'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView.builder(
            itemCount: groupsList.length, //products is data from back res
            itemBuilder:
                (context, index) => groupAsRowInTable(
                  groupsList[index],
                  index,
                  groupsList.length,
                ),
          ),
        ),
        ReusableAddCard(text: 'new_client'.tr, onTap: () {}),
      ],
    );
  }

  groupAsRowInTable(Map altCode, int index, int altCodesListLength) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        color: (index % 2 == 0) ? Primary.p10 : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: '${altCode['code'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['name'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          TableItem(
            text: '${altCode['currency'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['saleprice'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['discount'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['discount'] ?? ''}%',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['price_dicounted'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
        ],
      ),
    );
  }
}

class PropertiesTabInPriceLists extends StatefulWidget {
  const PropertiesTabInPriceLists({super.key});

  @override
  State<PropertiesTabInPriceLists> createState() =>
      _PropertiesTabInPriceListsState();
}

class _PropertiesTabInPriceListsState extends State<PropertiesTabInPriceLists> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gapH32,
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('vat_inclusive_prices'.tr),
                    leading: Checkbox(
                      value: cont.isVatInclusivePricesChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          cont.setIs1Checked(value!);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.46,
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        'prices_are_derived_from_another_price_list'.tr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      leading: Checkbox(
                        // checkColor: Colors.white,
                        // fillColor: MaterialStateProperty.resolveWith(getColor),
                        value: cont.isDerivedPricesChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            cont.setIs2Checked(value!);
                          });
                        },
                      ),
                    ),
                  ),
                  cont.isDerivedPricesChecked
                      ? DialogDropMenu(
                        controller: cont.derivedPriceListController,
                        optionsList:
                            cont.selectedPriceListIdForUpdate.isEmpty
                                ? cont.priceListsCods
                                : cont.priceListsCods
                                    .where(
                                      (item) =>
                                          cont.priceListsIds[cont.priceListsCods
                                              .indexOf(item)] !=
                                          cont.selectedPriceListIdForUpdate,
                                    )
                                    .toList(),
                        text: '',
                        hint: '',
                        onSelected: (val) {
                          var index = cont.priceListsCods.indexOf(val);
                          cont.setSelectedAnotherPriceList(
                            cont.priceListsIds[index],
                            cont.priceListsNames[index],
                            val,
                          );
                        },
                        rowWidth: MediaQuery.of(context).size.width * 0.15,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.15,
                      )
                      : const SizedBox(),
                ],
              ),
            ),
            gapH24,
            Row(
              children: [
                DialogDropMenu(
                  controller: cont.methodController,
                  optionsList: ['minus'.tr, 'plus'.tr],
                  rowWidth: MediaQuery.of(context).size.width * 0.1,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.1,
                  text: '',
                  onSelected: (val) {
                    cont.setSelectedMethod(val);
                  },
                  hint: 'minus'.tr,
                ),
                // ReusableDropDownMenuWithoutSearch(
                //   list: ['minus'.tr, 'plus'.tr],
                //   text: '',
                //   hint: 'minus'.tr,
                //   onSelected: (val) {
                //     cont.setSelectedMethod(val);
                //   },
                //   validationFunc: (val) {},
                //   rowWidth: MediaQuery.of(context).size.width * 0.1,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.1,
                // ),
                gapW6,
                DialogDropMenu(
                  controller: cont.commissionsPaymentController,
                  optionsList: [
                    'global_percentage'.tr,
                    'percentage_as_per_item_department'.tr,
                  ],
                  rowWidth: MediaQuery.of(context).size.width * 0.25,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                  text: '',
                  onSelected: (String? val) {
                    cont.setSelectedCommissionsPayment(val!);
                  },
                  hint: '',
                ),
                // ReusableDropDownMenuWithoutSearch(
                //   list: [
                //     'global_percentage'.tr,
                //     'percentage_as_per_item_department'.tr,
                //   ],
                //   text: '',
                //   hint: '',
                //   onSelected: (String? val) {
                //     cont.setSelectedCommissionsPayment(val!);
                //   },
                //   validationFunc: (val) {},
                //   rowWidth: MediaQuery.of(context).size.width * 0.25,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                // ),
                gapW6,
                ReusableInputNumberField(
                  controller: cont.adjustmentPercentageController,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.1,
                  rowWidth: MediaQuery.of(context).size.width * 0.1,
                  onChangedFunc: () {},
                  validationFunc: () {},
                  text: '',
                ),
                Text('  %', style: TextStyle(fontSize: 15)),
              ],
            ),
            gapH28,
            cont.selectedMethod == 'minus'.tr
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'at_transaction_time_display'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: 16,
                        // color: TypographyColor.textTable,
                      ),
                    ),
                    gapH6,
                   ReusableRadioBtns(
                     isRow: true,
                        groupVal:  cont.selectedDisplayModeRadio,
                        title1: 'net_prices'.tr,
                        title2: 'prices_with_visible_discount'.tr,
                        func: (value) {
                           cont.setSelectedRadio(value!);
                        },
                        width1: MediaQuery.of(context).size.width * 0.25,
                        width2: MediaQuery.of(context).size.width * 0.25,
                      ),
                    gapH6,
                  ],
                )
                : SizedBox(),
            ReusableButtonWithNoColor(
              width: MediaQuery.of(context).size.width * 0.1,
              height: 45,
              onTapFunction: () {
                showDialog<String>(
                  context: context,
                  builder:
                      (BuildContext context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                        ),
                        elevation: 0,
                        content: PricingWizard(),
                      ),
                );
              },
              btnText: 'pricing_wizard'.tr,
            ),
          ],
        );
      },
    );
  }
}

class PricingWizard extends StatefulWidget {
  const PricingWizard({super.key});

  @override
  State<PricingWizard> createState() => _PricingWizardState();
}

class _PricingWizardState extends State<PricingWizard> {
  int selectedTabIndex = 0;
  List tabsList = ['main', 'scope'];
  List tabsContent = [
    MainInPriceLists(isMobile: false),
    const ScopePage(isMobile: false),
  ];
  PriceListController priceListController = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.7,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(
                    text:
                        'Creating items prices [${cont.codeController.text}]'
                        ' ${cont.selectedAnotherPriceListCode.isNotEmpty ? 'based on prices derived from [${cont.selectedAnotherPriceListCode}]' : ''}',
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
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  cont.selectedPriceListIdForUpdate == ''?Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children:
                        tabsList
                            .map(
                              (element) => ReusableBuildTabChipItem(
                                name: element,
                                index: tabsList.indexOf(element),
                                function: () {
                                  setState(() {
                                    selectedTabIndex = tabsList.indexOf(
                                      element,
                                    );
                                  });
                                },
                                isClicked:
                                    selectedTabIndex ==
                                    tabsList.indexOf(element),
                              ),
                            )
                            .toList(),
                  ):Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children:
                        ['main']
                            .map(
                              (element) => ReusableBuildTabChipItem(
                                name: element,
                                index: tabsList.indexOf(element),
                                function: () {
                                  setState(() {
                                    selectedTabIndex = tabsList.indexOf(
                                      element,
                                    );
                                  });
                                },
                                isClicked:
                                    selectedTabIndex ==
                                    tabsList.indexOf(element),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              gapH16,
              tabsContent[selectedTabIndex],
            ],
          ),
        );
      },
    );
  }
}

class MainInPriceLists extends StatefulWidget {
  const MainInPriceLists({super.key, required this.isMobile});
  final bool isMobile;
  @override
  State<MainInPriceLists> createState() => _MainInPriceListsState();
}

class _MainInPriceListsState extends State<MainInPriceLists> {
  ExchangeRatesController exchangeRatesController = Get.find();
  @override
  void initState() {
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack(
      withUsd: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Column(
          children: [
            cont.selectedAnotherPriceListName.isNotEmpty
                ? Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.12,
                      child: Text('Source price-list'),
                    ),
                    ReusableShowInfoCard(
                      text:
                          '${cont.selectedAnotherPriceListCode}, ${cont.selectedAnotherPriceListName}',
                      isCentered: false,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                  ],
                )
                : SizedBox(),
            gapH6,
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.12,
                  child: Text('Target price-list'),
                ),
                ReusableShowInfoCard(
                  text:
                      '${cont.codeController.text}, ${cont.nameController.text}',
                  isCentered: false,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
              ],
            ),
            gapH6,
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.12,
                  child: Text('Derivation settings'),
                ),
                ReusableShowInfoCard(
                  text:
                      '${cont.selectedCommissionsPayment}, ${cont.adjustmentPercentageController.text}%',
                  isCentered: false,
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
              ],
            ),
            gapH16,
            GetBuilder<ExchangeRatesController>(
              builder: (currCont) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width:
                          widget.isMobile
                              ? MediaQuery.of(context).size.width * 0.25
                              : MediaQuery.of(context).size.width * 0.12,
                      child: Text('Convert to currency'),
                    ),
                    DropdownMenu<String>(
                      width:
                          widget.isMobile
                              ? MediaQuery.of(context).size.width * 0.3
                              : MediaQuery.of(context).size.width * 0.1,
                      // requestFocusOnTap: false,
                      enableSearch: true,
                      controller: cont.currencyController,
                      hintText: '',
                      inputDecorationTheme: InputDecorationTheme(
                        // filled: true,
                        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                        contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                        // outlineBorder: BorderSide(color: Colors.black,),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Primary.primary.withAlpha(
                              (0.2 * 255).toInt(),
                            ),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(9),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Primary.primary.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(9),
                          ),
                        ),
                      ),
                      // menuStyle: ,
                      menuHeight: 250,
                      dropdownMenuEntries:
                          currCont.currenciesSymbolsList
                              .map<DropdownMenuEntry<String>>((String option) {
                                return DropdownMenuEntry<String>(
                                  value: option,
                                  label: option,
                                );
                              })
                              .toList(),
                      enableFilter: true,
                      onSelected: (String? val) {
                        var index = currCont.currenciesSymbolsList.indexOf(
                          val!,
                        );
                        cont.setCurrency(
                          '${currCont.currenciesIdsList[index]}',
                          currCont.currenciesNamesList[index],
                          val,
                        );
                      },
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    Container(
                      height: widget.isMobile ? 55 : 47,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width:
                          widget.isMobile
                              ? MediaQuery.of(context).size.width * 0.2
                              : MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                        border: Border.all(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Text(cont.selectedCurrencyName)],
                      ),
                    ),
                  ],
                );
              },
            ),
            gapH16,
            Row(
              children: [
                DialogDropMenu(
                  controller: cont.roundMethodController,
                  optionsList: ['up', 'nearest'],
                  text: 'rounding_method'.tr,
                  hint: '',
                  onSelected: (val) {
                    cont.setSelectedRoundingMethod(val);
                  },
                  rowWidth: MediaQuery.of(context).size.width * 0.22,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.1,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                ReusableInputNumberField(
                  controller: cont.roundValueController,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.1,
                  rowWidth: MediaQuery.of(context).size.width * 0.1,
                  onChangedFunc: () {},
                  validationFunc: () {},
                  text: '',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ScopePage extends StatefulWidget {
  const ScopePage({super.key, required this.isMobile});
  final bool isMobile;
  @override
  State<ScopePage> createState() => _ScopePageState();
}

class _ScopePageState extends State<ScopePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogDropMenu(
                controller: cont.itemsController,
                optionsList: cont.itemsNamesList,
                text: 'item'.tr,
                hint:
                    cont.itemsNamesList[cont.itemsIdsList.indexOf(
                      cont.selectedItemId,
                    )],
                rowWidth:
                    widget.isMobile
                        ? MediaQuery.of(context).size.width * 0.9
                        : MediaQuery.of(context).size.width * 0.25,
                textFieldWidth:
                    widget.isMobile
                        ? MediaQuery.of(context).size.width * 0.65
                        : MediaQuery.of(context).size.width * 0.15,
                onSelected: (String? val) {
                  var index = cont.itemsNamesList.indexOf(val!);
                  cont.setSelectedItemId(cont.itemsIdsList[index]);
                },
              ),
              gapH24,
              DialogDropMenu(
                controller: cont.categoryController,
                optionsList: cont.categoriesNameList,
                text: 'category'.tr,
                hint:
                    cont.categoriesNameList[cont.categoriesIdsList.indexOf(
                      cont.selectedCategoryId,
                    )],
                rowWidth:
                    widget.isMobile
                        ? MediaQuery.of(context).size.width * 0.9
                        : MediaQuery.of(context).size.width * 0.25,
                textFieldWidth:
                    widget.isMobile
                        ? MediaQuery.of(context).size.width * 0.65
                        : MediaQuery.of(context).size.width * 0.15,
                onSelected: (String? val) {
                  var index = cont.categoriesNameList.indexOf(val!);
                  cont.setSelectedCategoryId(cont.categoriesIdsList[index]);
                },
              ),
              gapH24,
              Expanded(
                // height: MediaQuery.of(context).size.height * 0.35,
                child: ListView.builder(
                  itemCount:
                      cont.groupsList.length, //products is data from back res
                  itemBuilder:
                      (context, index) => GroupRow(
                        isMobile: widget.isMobile,
                        data: cont.groupsList[index],
                        index: index,
                      ),
                ),
              ),
              widget.isMobile ? gapH20 : SizedBox(),
              // Spacer()
            ],
          ),
        );
      },
    );
  }
}

class GroupRow extends StatefulWidget {
  const GroupRow({
    super.key,
    required this.data,
    required this.index,
    required this.isMobile,
  });
  final Map data;
  final int index;
  final bool isMobile;
  @override
  State<GroupRow> createState() => _GroupRowState();
}

class _GroupRowState extends State<GroupRow> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PriceListController>(
      builder: (cont) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width:
                    widget.isMobile
                        ? MediaQuery.of(context).size.width * 0.2
                        : MediaQuery.of(context).size.width * 0.10,
                child: Text(widget.data['name']),
              ),
              DropdownMenu<String>(
                width:
                    widget.isMobile
                        ? MediaQuery.of(context).size.width * 0.35
                        : MediaQuery.of(context).size.width * 0.15,
                // requestFocusOnTap: false,
                enableSearch: true,
                controller: cont.textEditingControllerForGroups[widget.index],
                hintText:
                    cont.selectedGroupsCodesForShow[widget.index].isNotEmpty
                        ? cont.selectedGroupsCodesForShow[widget.index][0]
                        : '',
                inputDecorationTheme: InputDecorationTheme(
                  // filled: true,
                  hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                  contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                  // outlineBorder: BorderSide(color: Colors.black,),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                ),
                // menuStyle: ,
                menuHeight: 250,
                dropdownMenuEntries:
                    cont.childGroupsCodes[widget.index]
                        .map<DropdownMenuEntry<String>>((String option) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                          );
                        })
                        .toList(),
                enableFilter: true,
                onSelected: (String? val) {
                  var index = cont.childGroupsCodes[widget.index].indexOf(val!);
                  cont.addIdToSelectedGroupsIdsList(
                    cont.groupsIds[widget.index][index],
                  );
                  cont.addSelectedGroupsIdsForShow([
                    cont.groupsIds[widget.index][index],
                  ], widget.index);
                  cont.addSelectedGroupsCodesForShow([val], widget.index);
                  cont.addSelectedGroupsNamesForShow([
                    cont.childGroupsNames[widget.index][index],
                  ], widget.index);
                },
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              Container(
                height: 47,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 3 : 10,
                ),
                width: MediaQuery.of(context).size.width * 0.15,
                // decoration: BoxDecoration(
                //   borderRadius:const BorderRadius.all( Radius.circular(9)),
                //   border:   Border.all(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
                // ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cont.selectedGroupsNamesForShow[widget.index].isNotEmpty
                          ? cont.selectedGroupsNamesForShow[widget.index][0]
                          : '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ZeroChangeDialog extends StatefulWidget {
  const ZeroChangeDialog({
    super.key,
  });

  @override
  State<ZeroChangeDialog> createState() => _ZeroChangeDialogState();
}

class _ZeroChangeDialogState extends State<ZeroChangeDialog> {
  PriceListController priceListController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GetBuilder<PriceListController>(
        builder: (cont) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DialogTitle(text: 'add_zero_change_pricelist_message'.tr),
              gapH32,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ReusableButtonWithColor(
                    btnText: 'continue'.tr,
                    radius: 9,
                    onTapFunction: () async {
                      showDialog<String>(
                        context: context,
                        builder:
                            (BuildContext context) => const AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                              ),
                              elevation: 0,
                              content: LoadingDialog(),
                            ),
                      );
                      if (cont.selectedPriceListIdForUpdate == '') {
                        var p = await storePriceList(
                          title: priceListController.nameController.text,
                          code: priceListController.codeController.text,
                          vatInclusivePrices:
                              priceListController.isVatInclusivePricesChecked
                                  ? '1'
                                  : '0',
                          derivedPrices:
                              priceListController.isDerivedPricesChecked
                                  ? '1'
                                  : '0',
                          pricelistId:
                              priceListController.selectedAnotherPriceListId,
                          type: 'percentage',
                          adjustmentPercentage:
                              priceListController.selectedMethod == 'MINUS' &&
                                      priceListController
                                              .adjustmentPercentageController
                                              .text !=
                                          '0'
                                  ? '-${priceListController.adjustmentPercentageController.text}'
                                  : priceListController
                                      .adjustmentPercentageController
                                      .text,
                          convertToCurrencyId:
                              priceListController.selectedCurrencyId,
                          roundingMethod:
                              priceListController.selectedRoundingMethod,
                          roundingPrecision:
                              priceListController.roundValueController.text,
                          transactionDisplayMode:
                              priceListController.selectedDisplayModeRadio == 1
                                  ? 'net'
                                  : 'visible_discount',
                          categories:
                              priceListController.selectedCategoriesIdsList,
                          itemGroups: priceListController.selectedGroupsIds,
                          singleItemId: priceListController.selectedItemId,
                        );
                        Get.back();
                        Get.back();
                        if (p['success'] == true) {
                          CommonWidgets.snackBar('Success', p['message']);
                          cont.setSelectedTabIndex(0);
                          priceListController.resetValues();
                          cont.getAllPricesListFromBack();
                        } else {
                          CommonWidgets.snackBar('error', p['message']);
                        }
                      }
                      else {
                        var p = await updatePriceList(
                          priceListId: cont.selectedPriceListIdForUpdate,
                          title: priceListController.nameController.text,
                          code: priceListController.codeController.text,
                          vatInclusivePrices:
                              priceListController.isVatInclusivePricesChecked
                                  ? '1'
                                  : '0',
                          derivedPrices:
                              priceListController.isDerivedPricesChecked
                                  ? '1'
                                  : '0',
                          pricelistId:
                              priceListController.selectedAnotherPriceListId,
                          type: 'percentage',
                          adjustmentPercentage:
                              priceListController.selectedMethod == 'MINUS'
                                  ? '-${priceListController.adjustmentPercentageController.text}'
                                  : priceListController
                                      .adjustmentPercentageController
                                      .text,
                          convertToCurrencyId:
                              priceListController.selectedCurrencyId,
                          roundingMethod:
                              priceListController.selectedRoundingMethod,
                          roundingPrecision:
                              priceListController.roundValueController.text,
                          transactionDisplayMode:
                              priceListController.selectedDisplayModeRadio == 1
                                  ? 'net'
                                  : 'visible_discount',
                          categories:
                              priceListController.selectedCategoriesIdsList,
                          itemGroups: priceListController.selectedGroupsIds,
                          singleItemId: priceListController.selectedItemId,
                        );
                        Get.back();
                        Get.back();
                        if (p['success'] == true) {
                          CommonWidgets.snackBar('Success', p['message']);
                          cont.setSelectedTabIndex(0);
                          priceListController.resetValues();
                          cont.getAllPricesListFromBack();
                        } else {
                          CommonWidgets.snackBar('error', p['message']);
                        }
                      }
                    },
                    width: MediaQuery.of(context).size.width * 0.08,
                    height: 50,
                  ),
                  ReusableButtonWithColor(
                    btnText: 'cancel'.tr,
                    radius: 9,
                    onTapFunction: () {
                      Get.back();
                    },
                    width: MediaQuery.of(context).size.width * 0.08,
                    height: 50,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
