import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../../../Controllers/home_controller.dart';
import '../../../../Widgets/page_title.dart';
import '../../../../Widgets/reusable_btn.dart';
import '../../../../Widgets/reusable_text_field.dart';
import '../../../../const/Sizes.dart';
import '../../../../const/colors.dart';
import '../../../Backend/CategoriesBackend/get_categories.dart';
import '../../../Backend/Transfers/Replenish/add_replenish.dart';

import '../../../Backend/Transfers/Replenish/get_data_create_replenishments.dart';
import '../../../Backend/Transfers/Replenish/update_replenishment.dart';
import '../../../Controllers/exchange_rates_controller.dart';
import '../../../Controllers/transfer_controller.dart';
import '../../../Controllers/warehouse_controller.dart';
import '../../../Widgets/TransferWidgets/reusable_show_info_card.dart';
import '../../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/dialog_drop_menu.dart';
import '../../../Widgets/loading.dart';
// import '../../../Widgets/reusable_add_card.dart';
import '../../../Widgets/loading_dialog.dart';
import '../../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../../../const/functions.dart';
import 'print_replenish.dart';

class UpdateReplenishmentDialog extends StatefulWidget {
  const UpdateReplenishmentDialog({super.key, required this.index, required this.info});
  final int index;
  final Map info;
  @override
  State<UpdateReplenishmentDialog> createState() => _UpdateReplenishmentDialogState();
}

class _UpdateReplenishmentDialogState extends State<UpdateReplenishmentDialog> {
  TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  late Uint8List imageFile;
  int currentStep = 0;
  int selectedTabIndex = 0;
  bool isLoading = false;
  List tabsList = ['order_lines', 'other_information'];
  String? selectedDestWrhs = '';
  String? selectedItem = '';
  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.09;
  final TransferController transferController = Get.find();
  final HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  String selectedCurrencyId = '';
  final WarehouseController warehouseController = Get.find();
  int progressVar = 0;
  Map data = {};
  // bool isInfoFetched = false;
  String replenishmentNumber = '';
  getFieldsForCreateTransferFromBack() async {
    // setState(() {
    //   currentStep = 0;
    //
    //
    //   selectedDestWrhs = '';
    //   progressVar = 0;
    //   replenishmentNumber = '';
      data = {};
      // transferController.transferToInReplenishController.text = '';
      transferController.setTransferToIdInReplenish('');
      currencyController.text = 'USD';
    // });
    // var p = await getReplenishmentsDataForCreate();
  }

  List<String> categoriesNameList = ['all_categories'.tr];
  List categoriesIds = ['0'];
  bool isCategoriesFetched = false;
  getCategoriesFromBack() async {
    var p = await getCategories('');
    // setState(() {
      for (var item in p) {
        categoriesNameList.add('${item['category_name']}');
        categoriesIds.add('${item['id']}');
        isCategoriesFetched = true;
      }
    // });
  }




  setData(){
    selectedTabIndex = 0;

    refController.text='${widget.info['reference'] ?? ''}';
    if(widget.info['currency']!=null){
      currencyController.text = '${widget.info['currency']['name'] ?? ''}';
      selectedCurrencyId = '${widget.info['currency']['id'] ?? ''}';
    }
    dateController.text='${widget.info['date'] ?? ''}'.substring(0,11);
    selectedDestWrhs='${widget.info['destWarehouse'] ?? ''}';
    transferController
        .transferToInReplenishController.text='${widget.info['destWarehouse'] ?? ''}';
    // transferToIdInReplenish=
    replenishmentNumber='${widget.info['replenishmentNumber'] ?? ''}';
    setItemsList();

  }

  setItemsList() async {
    transferController.quantitiesForUpdate={};
        var index = warehouseController
            .warehousesNameList
            .indexOf('${widget.info['destWarehouse'] ?? ''}');
        transferController
            .transferToIdInReplenish= warehouseController.warehouseIdsList[index];
        isLoading = true;
      transferController
          .isProductsFetched = false;
      transferController
          .getAllProductsFromBack(
        '',
        searchController.text,
        transferController
            .selectedCategoryId,
      );

      for (var item in widget.info['items']) {
          transferController.quantitiesForUpdate['${item['item_id']}']=
              '${item['replenished_qty']}';
      }
    }

  @override
  void initState() {
    getCategoriesFromBack();
    transferController.itemsListInReplenish = {};
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(text: 'update_replenishment'.tr),
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
                gapH32,


                gapH16,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Others.divider),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(9),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${widget.info['replenishmentNumber'] ?? ''}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: TypographyColor.titleTable,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width *
                                      0.05,
                                ),
                                DialogTextField(
                                  textEditingController: refController,
                                  text: '${'ref'.tr}:',
                                  hint: 'manual_reference'.tr,
                                  rowWidth:
                                  MediaQuery.of(context).size.width *
                                      0.18,
                                  textFieldWidth:
                                  MediaQuery.of(context).size.width *
                                      0.15,
                                  validationFunc: (val) {},
                                ),
                              ],
                            ),
                            gapH16,
                            GetBuilder<TransferController>(
                              builder: (transferCont) {
                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'transfer_to'.tr}*'),
                                    GetBuilder<WarehouseController>(
                                      builder: (cont) {
                                        return DropdownMenu<String>(
                                          width:
                                          MediaQuery.of(
                                            context,
                                          ).size.width *
                                              0.25,
                                          // requestFocusOnTap: false,
                                          enableSearch: true,
                                          controller:
                                          transferCont
                                              .transferToInReplenishController,
                                          hintText: '${'search'.tr}...',
                                          inputDecorationTheme: InputDecorationTheme(
                                            // filled: true,
                                            hintStyle: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                            contentPadding:
                                            const EdgeInsets.fromLTRB(
                                              20,
                                              0,
                                              25,
                                              5,
                                            ),
                                            // outlineBorder: BorderSide(color: Colors.black,),
                                            enabledBorder:
                                            OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                  (0.2 * 255)
                                                      .toInt(),
                                                ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                              const BorderRadius.all(
                                                Radius.circular(9),
                                              ),
                                            ),
                                            focusedBorder:
                                            OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                  (0.4 * 255)
                                                      .toInt(),
                                                ),
                                                width: 2,
                                              ),
                                              borderRadius:
                                              const BorderRadius.all(
                                                Radius.circular(9),
                                              ),
                                            ),
                                          ),
                                          // menuStyle: ,
                                          menuHeight: 250,
                                          dropdownMenuEntries:
                                          cont.warehousesNameList.map<
                                              DropdownMenuEntry<String>
                                          >((String option) {
                                            return DropdownMenuEntry<
                                                String
                                            >(
                                              value: option,
                                              label: option,
                                            );
                                          }).toList(),
                                          enableFilter: true,
                                          onSelected: (String? val) async {
                                            setState(() {
                                              selectedDestWrhs = val!;
                                              var index = cont
                                                  .warehousesNameList
                                                  .indexOf(val);
                                              transferCont
                                                  .setTransferToIdInReplenish(
                                                cont.warehouseIdsList[index],
                                              );
                                              isLoading = true;
                                            });
                                            transferController
                                                .isProductsFetched = false;
                                            transferController
                                                .getAllProductsFromBack(
                                              '',
                                              searchController.text,
                                              transferCont
                                                  .selectedCategoryId,
                                            );
                                            // for (int i = 0;
                                            // i <
                                            //     transferCont
                                            //         .itemsListInReplenish
                                            //         .length;
                                            // i++) {
                                            //   var keys = transferCont.itemsListInReplenish.keys.toList();
                                            //   var p = await getQTyOfItemInWarehouse(
                                            //       transferCont
                                            //           .itemsListInReplenish[keys[i]]['itemId'],
                                            //       transferController
                                            //           .transferToIdInReplenish);
                                            //   if ('$p' != '[]') {
                                            //     String val=formatPackagingInfo( p['qtyOnHandPackages']);
                                            //     transferController.setQtyOnHandInSourceInReplenish('${keys[i]}',
                                            //         val.isNotEmpty?val:  '0 ${p['item']['packageUnitName'] ?? ''}');
                                            //   }
                                            // }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.25,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('date'.tr),
                                  DialogDateTextField(
                                    textEditingController: dateController,
                                    text: '',
                                    textFieldWidth:
                                    MediaQuery.of(context).size.width *
                                        0.15,
                                    validationFunc: (val) {},
                                    onChangedFunc: (val) {
                                      dateController.text = val;
                                    },
                                    onDateSelected: (value) {
                                      dateController.text = value;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            gapH16,
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.2,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('cur'.tr),
                                  GetBuilder<ExchangeRatesController>(
                                    builder: (cont) {
                                      return DropdownMenu<String>(
                                        width:
                                        MediaQuery.of(
                                          context,
                                        ).size.width *
                                            0.1,
                                        // requestFocusOnTap: false,
                                        enableSearch: true,
                                        controller: currencyController,
                                        hintText: '',
                                        inputDecorationTheme: InputDecorationTheme(
                                          // filled: true,
                                          hintStyle: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                          contentPadding:
                                          const EdgeInsets.fromLTRB(
                                            20,
                                            0,
                                            25,
                                            5,
                                          ),
                                          // outlineBorder: BorderSide(color: Colors.black,),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Primary.primary
                                                  .withAlpha(
                                                (0.2 * 255).toInt(),
                                              ),
                                              width: 1,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Primary.primary
                                                  .withAlpha(
                                                (0.4 * 255).toInt(),
                                              ),
                                              width: 2,
                                            ),
                                            borderRadius:
                                            const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                        ),
                                        // menuStyle: ,
                                        menuHeight: 250,
                                        dropdownMenuEntries:
                                        cont.currenciesNamesList.map<
                                            DropdownMenuEntry<String>
                                        >((String option) {
                                          return DropdownMenuEntry<
                                              String
                                          >(
                                            value: option,
                                            label: option,
                                          );
                                        }).toList(),
                                        enableFilter: true,
                                        onSelected: (String? val) {
                                          setState(() {
                                            selectedItem = val!;
                                            var index = cont
                                                .currenciesNamesList
                                                .indexOf(val);
                                            selectedCurrencyId =
                                            cont.currenciesIdsList[index];
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            gapH16,
                            Text('${'total_qty'.tr}: '),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gapH16,
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: ReusableSearchTextField(
                        hint: '${"search".tr}...',
                        textEditingController: searchController,
                        onChangedFunc: (val) {},
                        validationFunc: (val) {},
                      ),
                    ),
                    gapW10,
                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width * 0.12,
                      requestFocusOnTap: false,
                      hintText: 'all_categories'.tr,
                      inputDecorationTheme: InputDecorationTheme(
                        // filled: true,
                        contentPadding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          25,
                          5,
                        ),
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
                      dropdownMenuEntries:
                      categoriesNameList.map<DropdownMenuEntry<String>>(
                            (String option) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                            // enabled: option.label != 'Grey',
                            // style: MenuItemButton.styleFrom(
                            // foregroundColor: color.color,
                            // ),
                          );
                        },
                      ).toList(),
                      onSelected: (String? val) {
                        setState(() {
                          var index = categoriesNameList.indexOf(val!);
                          transferController.setSelectedCategoryId(
                            categoriesIds[index],
                          );
                        });
                      },
                    ),
                    gapW10,
                    InkWell(
                      onTap: () async {
                        if (cont.transferToIdInReplenish != '') {
                          transferController.clearReplenishOrderLines();
                          transferController.getAllProductsFromBack(
                            '',
                            searchController.text,
                            cont.selectedCategoryId,
                          );
                        } else {
                          CommonWidgets.snackBar(
                            'error',
                            'you must choose a warehouse first',
                          );
                        }
                      },
                      child: Icon(Icons.search, color: Primary.primary),
                    ),
                  ],
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 0.0,
                      direction: Axis.horizontal,
                      children:
                      tabsList
                          .map(
                            (element) => _buildTabChipItem(
                          element,
                          tabsList.indexOf(element),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
                // tabsContent[selectedTabIndex],
                selectedTabIndex == 0
                    ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        // horizontal:
                        // MediaQuery.of(context).size.width *
                        //     0.01,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Primary.primary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          TableTitle(
                            text: 'code'.tr,
                            width:
                            MediaQuery.of(context).size.width * 0.12,
                          ),
                          TableTitle(
                            text: 'item'.tr,
                            width:
                            MediaQuery.of(context).size.width * 0.12,
                          ),
                          TableTitle(
                            text: 'description'.tr,
                            width:
                            MediaQuery.of(context).size.width * 0.12,
                          ),
                          TableTitle(
                            text: 'qty_available_at_wrhs'.tr,
                            width:
                            MediaQuery.of(context).size.width * 0.12,
                          ),
                          TableTitle(
                            text: 'replenish_qty'.tr,
                            width:
                            MediaQuery.of(context).size.width *
                                0.07,
                          ),
                          TableTitle(
                            text: 'pack'.tr,
                            width:
                            MediaQuery.of(context).size.width *
                                0.07,
                          ),
                          TableTitle(
                            text: 'unit_cost'.tr,
                            width:
                            MediaQuery.of(context).size.width *
                                0.07,
                          ),
                          TableTitle(
                            text: 'note'.tr,
                            width:
                            MediaQuery.of(context).size.width * 0.1,
                          ),
                          // TableTitle(
                          //   text: 'more_options'.tr,
                          //   width: MediaQuery.of(context).size.width *
                          //       0.07,
                          // ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                        MediaQuery.of(context).size.width * 0.01,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height:
                            cont.transferToIdInReplenish != ''
                                ? cont.productsList.length *
                                increment
                                : 50,
                            child:
                            // cont.transferToIdInReplenish != '' && !cont.isProductsFetched?
                            cont.isProductsFetched
                                ? Column(
                              children: List.generate(
                                cont
                                    .productsList
                                    .length, // products is data from back-end response
                                    (index) {
                                  return ReusableItemRow(
                                    index: index,
                                  );
                                },
                              ),
                            )
                                : Row(
                              children: [
                                isLoading
                                    ? loading()
                                    : SizedBox(),
                              ],
                            ),
                          ),
                          // Row(
                          //   children: [
                          //     ReusableAddCard(
                          //       text: 'item'.tr,
                          //       onTap: () {
                          //         if (cont.transferToIdInReplenish !=
                          //             '') {
                          //           addNewItem();
                          //         } else {
                          //           CommonWidgets.snackBar('error',
                          //               'you must choose a warehouse first');
                          //         }
                          //       },
                          //     ),
                          //     gapW32,
                          //     ReusableAddCard(
                          //       text: 'image'.tr,
                          //       onTap: () {
                          //         // addNewImage();
                          //       },
                          //     ),
                          //     gapW32,
                          //     ReusableAddCard(
                          //       text: 'note'.tr,
                          //       onTap: () {
                          //         // addNewNote();
                          //       },
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    gapH28,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ReusableButtonWithColor(
                          width:
                          MediaQuery.of(context).size.width * 0.15,
                          height: 45,
                          // isDisable: cont.itemsListInReplenish.isEmpty,
                          onTapFunction: () async {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                const AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(9)),
                                    ),
                                    elevation: 0,
                                    content: LoadingDialog()));
                            // bool isThereItemsEmpty = false;
                            // var keys =
                            // cont.itemsListInReplenish.keys.toList();
                            // for (int i = 0; i < keys.length; i++) {
                            //   if (cont.itemsListInReplenish[keys[i]]["itemId"] ==
                            //       '' ||
                            //       cont.itemsListInReplenish[keys[i]]["cost"] ==
                            //           '' ||
                            //       cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                            //           '' ||
                            //       cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                            //           '0') {
                            //     setState(() {
                            //       isThereItemsEmpty = true;
                            //     });
                            //     break;
                            //   }
                            // }
                            // if (isThereItemsEmpty) {
                            //   CommonWidgets.snackBar(
                            //     'error',
                            //     'check all order lines and enter the required fields',
                            //   );
                            // } else
                            {
                              var res = await updateReplenishment(
                                '${widget.info['id']}',
                                transferController
                                    .transferToIdInReplenish,
                                refController.text,
                                '',
                                dateController.text,
                                selectedCurrencyId,
                                transferController.itemsListInReplenish,
                              );
                              Get.back();
                              if (res['success'] == true) {
                                Get.back();
                                CommonWidgets.snackBar(
                                  'Success',
                                  res['message'],
                                );
                                //todo
                                // transferController.isReplenishmentInfoFetched = false;
                                transferController
                                    .getAllReplenishmentFromBack();
                                homeController.selectedTab.value =
                                'replenishment';
                              } else {
                                CommonWidgets.snackBar(
                                  'error',
                                  res['message'],
                                );
                              }
                            }
                          },
                          btnText: 'submit'.tr,
                        ),
                      ],
                    ),
                  ],
                )
                    : const SizedBox(),
                gapH40,
              ],
            ),
          ),
        );
      },
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
              topRight: Radius.circular(9),
            ),
          ),
        ),
        child: Container(
          width: name.length * 10, // MediaQuery.of(context).size.width * 0.09,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: selectedTabIndex == index ? Primary.p20 : Colors.white,
            border:
            selectedTabIndex == index
                ? Border(top: BorderSide(color: Primary.primary, width: 3))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                spreadRadius: 9,
                blurRadius: 9,
                // offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Primary.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  addNewItem(int index, Map p) {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    // int index = transferController.itemsListInReplenish.length + 1;
    // Widget p = ReusableItemRow(index: index);
    // transferController.addToOrderLinesInReplenishList(p);
    transferController.addToItemsListInReplenish('$index', p);
  }

  addAllItems() {
    for (int i = 0; i < transferController.productsList.length; i++) {
      Map p = {
        'itemId': '${transferController.productsList[i]['id']}',
        'itemCode': '${transferController.productsList[i]['mainCode']}',
        'mainDescription':
        '${transferController.productsList[i]['mainDescription']}',
        'replenishedQty': '',
        'replenishedQtyPackage': '',
        'cost': '${transferController.productsList[i]['id']}',
        'note': '',
        'qtyOnHandPackagesInSource': '',
        'productsPackages': <String>[],
      };
      addNewItem(i, p);
    }
  }

  addNewImage() {
    setState(() {
      listViewLength = listViewLength + 100;
    });
    GetBuilder<TransferController>(
      builder: (cont) {
        return InkWell(
          onTap: () async {
            final image = await ImagePickerHelper.pickImage();
            setState(() {
              imageFile = image!;
              cont.changeBoolVarInTransferOut(true);
              cont.increaseImageSpaceInTransferOut(90);
              listViewLength =
                  listViewLength + (cont.imageSpaceHeightInTransferOut) + 10;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: DottedBorder(
              dashPattern: const [10, 10],
              color: Others.borderColor,
              radius: const Radius.circular(9),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.63,
                height: cont.imageSpaceHeightInTransferOut,
                child:
                cont.imageAvailableInReplenish
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.memory(
                      imageFile,
                      height: cont.imageSpaceHeightInTransferOut,
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    gapW20,
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Others.iconColor,
                      size: 32,
                    ),
                    gapW20,
                    Text(
                      'drag_drop_image'.tr,
                      style: TextStyle(
                        color: TypographyColor.textTable,
                      ),
                    ),
                    Text(
                      'browse'.tr,
                      style: TextStyle(color: Primary.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    // transferController.addToOrderLinesInReplenishList(p);
  }

  addNewNote() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: TextEditingController(), //todo
        isPasswordField: false,
        hint: 'note'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    // transferController.addToOrderLinesInReplenishList(p);
  }

  List<Step> getSteps() => [
    Step(
      title: const Text(''),
      content: Container(
        //page
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 1,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 2,
    ),
  ];
}

class ReusableItemRow extends StatefulWidget {
  const ReusableItemRow({super.key, required this.index, this.isMobile=false});
  final int index;
  final bool isMobile;

  @override
  State<ReusableItemRow> createState() => _ReusableItemRowState();
}

class _ReusableItemRowState extends State<ReusableItemRow> {
  final TransferController transferController = Get.find();
  String qty = '0';
  String qtyOnHandPackagesInSource = '0';
  TextEditingController qtyController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController packageController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController productController = TextEditingController();
  List<String> productsPackages = [];
  String selectedPackage = '';
  // String selectedItemId = '';
  bool isDataFetched = false;
  String note = '';
  String defaultTransactionPackageType = '';

  getInfo() async {
    // setState(() {
      Map p = transferController.productsList[widget.index];
      defaultTransactionPackageType =
      '${p['defaultTransactionPackageType'] ?? ''}';
      costController.text = '${p['unitCost'] ?? '0'}';
      if (p['packageUnitName'] != null) {
        productsPackages.add(p['packageUnitName']);
      }
      if (p['packageSetName'] != null) {
        productsPackages.add(p['packageSetName']);
      }
      if (p['packageSupersetName'] != null) {
        productsPackages.add(p['packageSupersetName']);
      }
      if (p['packagePaletteName'] != null) {
        productsPackages.add(p['packagePaletteName']);
      }
      if (p['packageContainerName'] != null) {
        productsPackages.add(p['packageContainerName']);
      }
      defaultTransactionPackageType =
      '${p['defaultTransactionPackageType'] ?? '1'}';
      if (defaultTransactionPackageType == '1') {
        packageController.text = p['packageUnitName'];
      } else if (defaultTransactionPackageType == '2') {
        packageController.text = p['packageSetName'];
      } else if (defaultTransactionPackageType == '3') {
        packageController.text = p['packageSupersetName'];
      } else if (defaultTransactionPackageType == '4') {
        packageController.text = p['packagePaletteName'];
      } else if (defaultTransactionPackageType == '5') {
        packageController.text = p['packageContainerName'];
      }
      for (int j = 0; j < p['warehouses'].length; j++) {
        if ('${p['warehouses'][j]['id']}' ==
            transferController.transferToIdInReplenish.toString()) {
          setState(() {
            Map<String, dynamic> qtyOnHandPackagesInSourceMap =
            p['warehouses'][j]['qty_in_default_packaging'];
            qtyOnHandPackagesInSource = formatPackagingInfo(
              qtyOnHandPackagesInSourceMap,
            );
          });
        }
      }
      isDataFetched = true;
    // });
  }

  addTheItemToItemsListInReplenish() {
    if (!transferController.itemsListInReplenish.containsKey(
      '${widget.index}',
    )) {
      transferController.addToItemsListInReplenishWithoutSetState('${widget.index}', {
        'itemId': '${transferController.productsList[widget.index]['id']}',
        'itemCode':
        '${transferController.productsList[widget.index]['mainCode']}',
        'mainDescription':
        '${transferController.productsList[widget.index]['mainDescription']}',
        'replenishedQty': qty,
        'replenishedQtyPackage': packageController.text,
        'cost': costController.text,
        'note': noteController.text,
        'qtyOnHandPackagesInSource': qtyOnHandPackagesInSource,
        'productsPackages': <String>[],
      });
    }
  }

  String? dropDownValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getInfo();
    if(transferController.quantitiesForUpdate.keys.contains('${transferController.productsIds[widget.index]}')) {
      qtyController.text =
      transferController.quantitiesForUpdate['${transferController.productsIds[widget.index]}'];
      addTheItemToItemsListInReplenish();
      transferController.itemsListInReplenish[widget.index
          .toString()]['replenishedQty']=transferController.quantitiesForUpdate['${transferController.productsIds[widget.index]}'];

    }
    if (transferController.itemsListInReplenish['${widget.index}'] != null) {
      qtyController.text =
      transferController.itemsListInReplenish[widget.index
          .toString()]['replenishedQty'];
      packageController.text =
      transferController.itemsListInReplenish[widget.index
          .toString()]['replenishedQtyPackage'];
      costController.text =
      transferController.itemsListInReplenish[widget.index
          .toString()]['cost'];
      noteController.text =
      transferController.itemsListInReplenish[widget.index
          .toString()]['note'];
      productController.text =
      transferController.itemsListInReplenish[widget.index
          .toString()]['itemCode'];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
      builder: (cont) {
        return Container(
          // height: Sizes.deviceHeight * 0.08,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container(
                //   width: MediaQuery.of(context).size.width * 0.02,
                //   height: 20,
                //   margin: const EdgeInsets.symmetric(vertical: 15),
                //   decoration: const BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage('assets/images/newRow.png'),
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // ),
                ReusableShowInfoCard(
                  text: cont.productsList[widget.index]['mainCode'],
                  width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.12,
                ),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(
                  text: cont.productsList[widget.index]['item_name'],
                  width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.12,
                ),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(
                  text: cont.productsList[widget.index]['mainDescription'],
                  width: widget.isMobile?150:MediaQuery.of(context).size.width * 0.12,
                ),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(
                  text: qtyOnHandPackagesInSource,
                  width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.12,
                ),
                widget.isMobile?gapW4:SizedBox(),
                SizedBox(
                    width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.07,
                    child:TextFormField(
                        autofocus: cont.focusIndex==widget.index,
                        focusNode:cont.focusIndex==widget.index? cont.focus:null,
                        controller: qtyController,
                        textAlign: TextAlign.center,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: '0',
                          contentPadding:widget.isMobile? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0):const EdgeInsets.fromLTRB(10, 0, 25, 5),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 10.0,
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(width: 1, color: Colors.red),
                          ),
                        ),
                        validator: (String? value) {
                          if (value!.isEmpty ) {
                            return 'required field';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          _formKey.currentState!.validate();
                          addTheItemToItemsListInReplenish();
                          cont.setReplenishedQtyInReplenish('${widget.index}', val);
                          setState(() {
                            qty = val;
                          });
                        },
                        // onFieldSubmitted: (_) {
                        //   if (widget.nextFocusNode != null) {
                        //     FocusScope.of(context).requestFocus(widget.nextFocusNode);
                        //   }
                        // },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                          signed: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                          // NumberFormatter(),
                          // WhitelistingTextInputFormatter.digitsOnly
                        ])

                  // ReusableNumberField(
                  //   textEditingController: qtyController,
                  //   isPasswordField: false,
                  //   isCentered: true,
                  //   hint: '0',
                  //   onChangedFunc: (val) {
                  //     _formKey.currentState!.validate();
                  //     addTheItemToItemsListInReplenish();
                  //     // cont.setItemIdInReplenish(
                  //     //     '${widget.index}', '${cont.productsList[widget.index]['id']}');
                  //     // cont.setItemNameInReplenish('${widget.index}',cont.productsList[widget.index]['item_name']);
                  //     cont.setReplenishedQtyInReplenish('${widget.index}', val);
                  //     setState(() {
                  //       qty = val;
                  //     });
                  //   },
                  //   validationFunc: (String? value) {
                  //     if (value!.isEmpty || double.parse(value) <= 0) {
                  //       return 'must be >0';
                  //     }
                  //     return null;
                  //   },
                  // ),
                ),
                widget.isMobile?gapW4:SizedBox(),
                DialogDropMenu(
                  optionsList: productsPackages,
                  text: '',
                  hint: '',
                  controller: packageController,
                  rowWidth:widget.isMobile?120: MediaQuery.of(context).size.width * 0.07,
                  textFieldWidth: widget.isMobile?120:MediaQuery.of(context).size.width * 0.07,
                  onSelected: (value) {
                    addTheItemToItemsListInReplenish();
                    cont.setReplenishedQtyPackageIdInReplenish(
                      '${widget.index}',
                      value,
                    );
                    setState(() {
                      selectedPackage = value;
                    });
                  },
                ),
                widget.isMobile?gapW4:SizedBox(),
                SizedBox(
                  width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.07,
                  child: ReusableNumberField(
                    textEditingController: costController,
                    isPasswordField: false,
                    isCentered: true,
                    hint: '0',
                    onChangedFunc: (val) {
                      addTheItemToItemsListInReplenish();
                      _formKey.currentState!.validate();
                      cont.setCostItemInReplenish('${widget.index}', val);
                    },
                    validationFunc: (String? value) {
                      if (value!.isEmpty) {
                        return 'required field';
                      }
                      return null;
                    },
                  ),
                ),
                widget.isMobile?gapW4:SizedBox(),
                SizedBox(
                  width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.1,
                  child: ReusableTextField(
                    onChangedFunc: (val) {
                      addTheItemToItemsListInReplenish();
                      cont.setNoteInReplenish('${widget.index}', val);
                      setState(() {
                        note = val;
                      });
                    },
                    validationFunc: (val) {},
                    hint: '',
                    isPasswordField: false,
                    textEditingController: noteController,
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

class MobileReplenish extends StatefulWidget {
  const MobileReplenish({super.key});

  @override
  State<MobileReplenish> createState() => _MobileReplenishState();
}

class _MobileReplenishState extends State<MobileReplenish> {
  TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  late Uint8List imageFile;
  int currentStep = 0;
  int selectedTabIndex = 0;
  bool isLoading = false;
  List tabsList = ['order_lines', 'other_information'];
  String? selectedDestWrhs = '';
  String? selectedItem = '';
  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;
  final TransferController transferController = Get.find();
  final HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  String selectedCurrencyId = '';
  final WarehouseController warehouseController = Get.find();
  int progressVar = 0;
  Map data = {};
  bool isInfoFetched = false;
  String replenishmentNumber = '';
  getFieldsForCreateTransferFromBack() async {
    setState(() {
      currentStep = 0;
      selectedTabIndex = 0;
      selectedItem = '';
      selectedDestWrhs = '';
      progressVar = 0;
      replenishmentNumber = '';
      data = {};
      transferController.transferToInReplenishController.text = '';
      transferController.setTransferToIdInReplenish('');
      currencyController.text = 'USD';
    });
    var p = await getReplenishmentsDataForCreate();
    if ('$p' != '[]') {
      setState(() {
        replenishmentNumber = '${p['replenishmentNumber']}';
        isInfoFetched = true;
      });
    }
  }

  List<String> categoriesNameList = ['all_categories'.tr];
  List categoriesIds = ['0'];
  bool isCategoriesFetched = false;
  getCategoriesFromBack() async {
    var p = await getCategories('');
    setState(() {
      for (var item in p) {
        categoriesNameList.add('${item['category_name']}');
        categoriesIds.add('${item['id']}');
        isCategoriesFetched = true;
      }
    });
  }
  List<FocusNode> focusNodes = [];

  @override
  void dispose() {
    // Dispose FocusNodes
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    getCategoriesFromBack();
    transferController.itemsListInReplenish = {};
    setState(() {
      listViewLength = Sizes.deviceHeight * 0.08;
    });
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getFieldsForCreateTransferFromBack();
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    // warehouseController.resetValues();
    warehouseController.getWarehousesFromBack();
    // transferController.getAllProductsFromBack('');
    transferController.resetReplenish();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isInfoFetched
        ? GetBuilder<TransferController>(
      builder: (cont) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [PageTitle(text: 'replenish'.tr)],
                ),
                gapH16,
                Row(
                  children: [
                    UnderTitleBtn(
                      text: 'preview'.tr,
                      onTap: () {
                        bool isThereItemsEmpty = false;
                        var keys =
                        cont.itemsListInReplenish.keys.toList();
                        for (int i = 0; i < keys.length; i++) {
                          if (cont.itemsListInReplenish[keys[i]]["itemId"] ==
                              '' ||
                              cont.itemsListInReplenish[keys[i]]["cost"] ==
                                  '' ||
                              cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                                  '' ||
                              cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                                  '0') {
                            setState(() {
                              isThereItemsEmpty = true;
                            });
                            break;
                          }
                        }
                        if (isThereItemsEmpty) {
                          CommonWidgets.snackBar(
                            'error',
                            'check all order lines and enter the required fields',
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return PrintReplenish(
                                  currency: currencyController.text,
                                  replenishNumber: replenishmentNumber,
                                  receivedDate: '',
                                  creationDate: dateController.text,
                                  ref: refController.text,
                                  destWarehouse: selectedDestWrhs ?? '',
                                  status: 'sent',
                                  rowsInListViewInReplenish:
                                  cont.itemsListInReplenish,
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                    UnderTitleBtn(
                      text: 'submit_and_preview'.tr,
                      onTap: () async {
                        bool isThereItemsEmpty = false;
                        var keys =
                        cont.itemsListInReplenish.keys.toList();
                        for (int i = 0; i < keys.length; i++) {
                          if (cont.itemsListInReplenish[keys[i]]["itemId"] ==
                              '' ||
                              cont.itemsListInReplenish[keys[i]]["cost"] ==
                                  '' ||
                              cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                                  '' ||
                              cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                                  '0') {
                            setState(() {
                              isThereItemsEmpty = true;
                            });
                            break;
                          }
                        }
                        if (isThereItemsEmpty) {
                          CommonWidgets.snackBar(
                            'error',
                            'check all order lines and enter the required fields',
                          );
                        } else {
                          var res = await addReplenishment(
                            transferController.transferToIdInReplenish,
                            refController.text,
                            '',
                            dateController.text,
                            selectedCurrencyId,
                            transferController.itemsListInReplenish,
                          );
                          if (res['success'] == true) {
                            CommonWidgets.snackBar(
                              'Success',
                              res['message'],
                            );
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return PrintReplenish(
                                    currency: currencyController.text,
                                    replenishNumber:
                                    replenishmentNumber,
                                    receivedDate: '',
                                    creationDate: dateController.text,
                                    ref: refController.text,
                                    destWarehouse:
                                    selectedDestWrhs ?? '',
                                    status: 'sent',
                                    rowsInListViewInReplenish:
                                    cont.itemsListInReplenish,
                                  );
                                },
                              ),
                            );
                          } else {
                            CommonWidgets.snackBar(
                              'error',
                              res['message'],
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                gapH16,
                Row(
                  children: [
                    ReusableTimeLineTile(
                        id: 0,
                        progressVar: progressVar,
                        isFirst: true,
                        isLast: false,
                        isPast: true,
                        isDesktop: false,
                        text: 'processing'.tr),
                    ReusableTimeLineTile(
                        id: 1,
                        progressVar: progressVar,
                        isFirst: false,
                        isLast: false,
                        isPast: false,
                        isDesktop: false,
                        text: 'pending'.tr),
                    ReusableTimeLineTile(
                      id: 2,
                      progressVar: progressVar,
                      isFirst: false,
                      isLast: true,
                      isPast: false,
                      isDesktop: false,
                      text: 'received'.tr,
                    ),
                  ],
                ),
                gapH16,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Others.divider),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(9),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          isInfoFetched
                              ? Text(
                            replenishmentNumber,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: TypographyColor.titleTable,
                            ),
                          )
                              : const CircularProgressIndicator(),
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.width *
                                0.1,
                          ),
                          DialogTextField(
                            textEditingController: refController,
                            text: '${'ref'.tr}:',
                            hint: 'manual_reference'.tr,
                            rowWidth:
                            MediaQuery.of(context).size.width *
                                0.45,
                            textFieldWidth:
                            MediaQuery.of(context).size.width *
                                0.35,
                            validationFunc: (val) {},
                          ),
                        ],
                      ),
                      gapH16,
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('date'.tr),
                          DialogDateTextField(
                            textEditingController: dateController,
                            text: '',
                            textFieldWidth:
                            MediaQuery.of(context).size.width *
                                0.5,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              dateController.text = val;
                            },
                            onDateSelected: (value) {
                              dateController.text = value;
                            },
                          ),
                        ],
                      ),
                      gapH16,
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('cur'.tr),
                          GetBuilder<ExchangeRatesController>(
                            builder: (cont) {
                              return DropdownMenu<String>(
                                width:
                                MediaQuery.of(
                                  context,
                                ).size.width *
                                    0.5,
                                // requestFocusOnTap: false,
                                enableSearch: true,
                                controller: currencyController,
                                hintText: '',
                                inputDecorationTheme: InputDecorationTheme(
                                  // filled: true,
                                  hintStyle: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  contentPadding:
                                  const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    25,
                                    5,
                                  ),
                                  // outlineBorder: BorderSide(color: Colors.black,),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Primary.primary
                                          .withAlpha(
                                        (0.2 * 255).toInt(),
                                      ),
                                      width: 1,
                                    ),
                                    borderRadius:
                                    const BorderRadius.all(
                                      Radius.circular(9),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Primary.primary
                                          .withAlpha(
                                        (0.4 * 255).toInt(),
                                      ),
                                      width: 2,
                                    ),
                                    borderRadius:
                                    const BorderRadius.all(
                                      Radius.circular(9),
                                    ),
                                  ),
                                ),
                                // menuStyle: ,
                                menuHeight: 250,
                                dropdownMenuEntries:
                                cont.currenciesNamesList.map<
                                    DropdownMenuEntry<String>
                                >((String option) {
                                  return DropdownMenuEntry<
                                      String
                                  >(
                                    value: option,
                                    label: option,
                                  );
                                }).toList(),
                                enableFilter: true,
                                onSelected: (String? val) {
                                  setState(() {
                                    selectedItem = val!;
                                    var index = cont
                                        .currenciesNamesList
                                        .indexOf(val);
                                    selectedCurrencyId =
                                    cont.currenciesIdsList[index];
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      gapH16,
                      GetBuilder<TransferController>(
                        builder: (transferCont) {
                          return Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${'transfer_to'.tr}*'),
                              GetBuilder<WarehouseController>(
                                builder: (cont) {
                                  return DropdownMenu<String>(
                                    width:
                                    MediaQuery.of(
                                      context,
                                    ).size.width *
                                        0.5,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller:
                                    transferCont
                                        .transferToInReplenishController,
                                    hintText: '${'search'.tr}...',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding:
                                      const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      // outlineBorder: BorderSide(color: Colors.black,),
                                      enabledBorder:
                                      OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary
                                              .withAlpha(
                                            (0.2 * 255)
                                                .toInt(),
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder:
                                      OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary
                                              .withAlpha(
                                            (0.4 * 255)
                                                .toInt(),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius:
                                        const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                    cont.warehousesNameList.map<
                                        DropdownMenuEntry<String>
                                    >((String option) {
                                      return DropdownMenuEntry<
                                          String
                                      >(
                                        value: option,
                                        label: option,
                                      );
                                    }).toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) async {
                                      setState(() {
                                        selectedDestWrhs = val!;
                                        var index = cont
                                            .warehousesNameList
                                            .indexOf(val);
                                        transferCont
                                            .setTransferToIdInReplenish(
                                          cont.warehouseIdsList[index],
                                        );
                                        isLoading = true;
                                      });
                                      transferController
                                          .isProductsFetched = false;
                                      transferController
                                          .getAllProductsFromBack(
                                        '',
                                        searchController.text,
                                        transferCont
                                            .selectedCategoryId,
                                      );
                                      setState(() {
                                        focusNodes=[];
                                      });
                                      for (int i = 0; i < transferController.productsList.length; i++) {
                                        focusNodes.add(FocusNode());
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                gapH16,
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ReusableSearchTextField(
                        hint: '${"search".tr}...',
                        textEditingController: searchController,
                        onChangedFunc: (val) {},
                        validationFunc: (val) {},
                      ),
                    ),
                    gapW10,
                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width * 0.35,
                      requestFocusOnTap: false,
                      hintText: 'all_categories'.tr,
                      inputDecorationTheme: InputDecorationTheme(
                        // filled: true,
                        contentPadding: const EdgeInsets.fromLTRB(
                          5,
                          0,
                          2,
                          5,
                        ),
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
                      dropdownMenuEntries:
                      categoriesNameList.map<DropdownMenuEntry<String>>(
                            (String option) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                            // enabled: option.label != 'Grey',
                            // style: MenuItemButton.styleFrom(
                            // foregroundColor: color.color,
                            // ),
                          );
                        },
                      ).toList(),
                      onSelected: (String? val) {
                        setState(() {
                          var index = categoriesNameList.indexOf(val!);
                          transferController.setSelectedCategoryId(
                            categoriesIds[index],
                          );
                        });
                      },
                    ),
                    gapW10,
                    InkWell(
                      onTap: () async {
                        if (cont.transferToIdInReplenish != '') {
                          transferController.clearReplenishOrderLines();
                          transferController.getAllProductsFromBack(
                            '',
                            searchController.text,
                            cont.selectedCategoryId,
                          );
                          setState(() {
                            focusNodes=[];
                          });
                          for (int i = 0; i < cont.productsList.length; i++) {
                            focusNodes.add(FocusNode());
                          }
                        } else {
                          CommonWidgets.snackBar(
                            'error',
                            'you must choose a warehouse first',
                          );
                        }
                      },
                      child: Icon(Icons.search, color: Primary.primary),
                    ),
                  ],
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 0.0,
                      direction: Axis.horizontal,
                      children:
                      tabsList
                          .map(
                            (element) => _buildTabChipItem(
                          element,
                          tabsList.indexOf(element),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
                // tabsContent[selectedTabIndex],
                selectedTabIndex == 0
                    ? Column(
                  children: [
                    SingleChildScrollView(
                      child: Row(
                        children: [ Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric( vertical: 15),
                                  decoration: BoxDecoration(
                                      color: Primary.primary,
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(6))),
                                  child:Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        TableTitle(
                                          text: 'code'.tr,
                                          width:
                                          150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'item'.tr,
                                          width:
                                          150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'description'.tr,
                                          width:
                                          150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'qty_available_at_wrhs'.tr,
                                          width:150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'replenish_qty'.tr,
                                          width:150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'pack'.tr,
                                          width:120,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'unit_cost'.tr,
                                          width:150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'note'.tr,
                                          width:
                                          150,
                                        ),
                                        // TableTitle(
                                        //   text: 'more_options'.tr,
                                        //   width: MediaQuery.of(context).size.width *
                                        //       0.07,
                                        // ),
                                      ]
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  child:  cont.isProductsFetched
                                      ? Column(
                                    children: List.generate(
                                      cont
                                          .productsList
                                          .length, // products is data from back-end response
                                          (index) {
                                        return ReusableItemRow(
                                            index: index,isMobile: true,
                                        );
                                      },
                                    ),
                                  )
                                      : Row(
                                    children: [
                                      isLoading
                                          ? loading()
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),],
                      ),
                    ),
                    gapH28,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ReusableButtonWithColor(
                          width:
                          MediaQuery.of(context).size.width * 0.35,
                          height: 45,
                          isDisable: cont.itemsListInReplenish.isEmpty,
                          onTapFunction: () async {
                            bool isThereItemsEmpty = false;
                            var keys =
                            cont.itemsListInReplenish.keys.toList();
                            for (int i = 0; i < keys.length; i++) {
                              if (cont.itemsListInReplenish[keys[i]]["itemId"] ==
                                  '' ||
                                  cont.itemsListInReplenish[keys[i]]["cost"] ==
                                      '' ||
                                  cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                                      '' ||
                                  cont.itemsListInReplenish[keys[i]]["replenishedQty"] ==
                                      '0') {
                                setState(() {
                                  isThereItemsEmpty = true;
                                });
                                break;
                              }
                            }
                            if (isThereItemsEmpty) {
                              CommonWidgets.snackBar(
                                'error',
                                'check all order lines and enter the required fields',
                              );
                            } else {
                              var res = await addReplenishment(
                                transferController
                                    .transferToIdInReplenish,
                                refController.text,
                                '',
                                dateController.text,
                                selectedCurrencyId,
                                transferController.itemsListInReplenish,
                              );
                              if (res['success'] == true) {
                                CommonWidgets.snackBar(
                                  'Success',
                                  res['message'],
                                );
                                //todo
                                // transferController.isReplenishmentInfoFetched = false;
                                transferController
                                    .getAllReplenishmentFromBack();
                                homeController.selectedTab.value =
                                'replenishment';
                              } else {
                                CommonWidgets.snackBar(
                                  'error',
                                  res['message'],
                                );
                              }
                            }
                          },
                          btnText: 'submit'.tr,
                        ),
                      ],
                    ),
                    gapH28,
                  ],
                )
                    : const SizedBox(),
                gapH40,
              ],
            ),
          ),
        );
      },
    )
        : const CircularProgressIndicator();
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
              topRight: Radius.circular(9),
            ),
          ),
        ),
        child: Container(
          width: name.length * 10, // MediaQuery.of(context).size.width * 0.09,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: selectedTabIndex == index ? Primary.p20 : Colors.white,
            border:
            selectedTabIndex == index
                ? Border(top: BorderSide(color: Primary.primary, width: 3))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                spreadRadius: 9,
                blurRadius: 9,
                // offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Primary.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  addNewItem(int index, Map p) {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    // int index = transferController.itemsListInReplenish.length + 1;
    // Widget p = ReusableItemRow(index: index);
    // transferController.addToOrderLinesInReplenishList(p);
    transferController.addToItemsListInReplenish('$index', p);
  }

  addAllItems() {
    for (int i = 0; i < transferController.productsList.length; i++) {
      Map p = {
        'itemId': '${transferController.productsList[i]['id']}',
        'itemCode': '${transferController.productsList[i]['mainCode']}',
        'mainDescription':
        '${transferController.productsList[i]['mainDescription']}',
        'replenishedQty': '0',
        'replenishedQtyPackage': '',
        'cost': '${transferController.productsList[i]['id']}',
        'note': '',
        'qtyOnHandPackagesInSource': '',
        'productsPackages': <String>[],
      };
      addNewItem(i, p);
    }
  }

  addNewImage() {
    setState(() {
      listViewLength = listViewLength + 100;
    });
    GetBuilder<TransferController>(
      builder: (cont) {
        return InkWell(
          onTap: () async {
            final image = await ImagePickerHelper.pickImage();
            setState(() {
              imageFile = image!;
              cont.changeBoolVarInTransferOut(true);
              cont.increaseImageSpaceInTransferOut(90);
              listViewLength =
                  listViewLength + (cont.imageSpaceHeightInTransferOut) + 10;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: DottedBorder(
              dashPattern: const [10, 10],
              color: Others.borderColor,
              radius: const Radius.circular(9),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.63,
                height: cont.imageSpaceHeightInTransferOut,
                child:
                cont.imageAvailableInReplenish
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.memory(
                      imageFile,
                      height: cont.imageSpaceHeightInTransferOut,
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    gapW20,
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Others.iconColor,
                      size: 32,
                    ),
                    gapW20,
                    Text(
                      'drag_drop_image'.tr,
                      style: TextStyle(
                        color: TypographyColor.textTable,
                      ),
                    ),
                    Text(
                      'browse'.tr,
                      style: TextStyle(color: Primary.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    // transferController.addToOrderLinesInReplenishList(p);
  }

  addNewNote() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: TextEditingController(), //todo
        isPasswordField: false,
        hint: 'note'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    // transferController.addToOrderLinesInReplenishList(p);
  }

  List<Step> getSteps() => [
    Step(
      title: const Text(''),
      content: Container(
        //page
      ),
      isActive: currentStep >= 0,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 1,
    ),
    Step(
      title: const Text(''),
      content: Container(),
      isActive: currentStep >= 2,
    ),
  ];
}
