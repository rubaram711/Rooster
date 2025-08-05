import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import 'package:rooster_app/Screens/Configuration/sup_references_dialog.dart';
import '../../../Backend/Quotations/get_quotation_create_info.dart';
import '../../../Backend/Quotations/store_quotation.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Controllers/quotations_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/table_title.dart';
// import 'package:time_machine/time_machine.dart';


class CreateNewPurchaseInvoice extends StatefulWidget {
  const CreateNewPurchaseInvoice({super.key});

  @override
  State<CreateNewPurchaseInvoice> createState() => _CreateNewPurchaseInvoiceState();
}

class _CreateNewPurchaseInvoiceState extends State<CreateNewPurchaseInvoice> {
  // bool imageAvailable=false;
  TextEditingController globalDiscController = TextEditingController();
  TextEditingController specialDiscController = TextEditingController();
  TextEditingController controller = TextEditingController();


  TextEditingController commissionController = TextEditingController();
  TextEditingController totalCommissionController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String
  selectedPaymentTerm = '',
      selectedPriceList = '',
      selectedCurrency = '',
      termsAndConditions = '',
      specialDisc = '',
      globalDisc = '';
  late Uint8List imageFile;

  int currentStep = 0;
  int selectedTabIndex = 0;
  GlobalKey accMoreKey = GlobalKey();
  GlobalKey accMoreKey3 = GlobalKey();
  List tabsList = [
    'order_lines',
    'other_information',
  ];
  String selectedTab = 'order_lines'.tr;
  String? selectedItem = '';

  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;
  // double imageSpaceHeight = Sizes.deviceHeight * 0.1;
  // List<Widget> orderLinesList = [];


  // final PurchaseInvoiceController purchaseinvoiceController = Get.find();
  final QuotationsController quotationController = Get.find();
  final HomeController homeController = Get.find();
  int progressVar = 0;
  Map data = {};
  // bool isOrdersInfoFetched = false;
  bool isPurchaseInvoicesInfoFetched = false;
  List<String> customerNameList = [];
  List customerIdsList = [];
  String selectedCustomerIds = '';
  String quotationNumber = '';
  getFieldsForCreateQuotationFromBack() async {
    setState(() {
      selectedPaymentTerm = '';
      selectedPriceList = '';
      selectedCurrency = '';
      termsAndConditions = '';
      specialDisc = '';
      globalDisc = '';
      currentStep = 0;
      selectedTabIndex = 0;
      selectedItem = '';
      progressVar = 0;
      selectedCustomerIds = '';
      quotationNumber = '';
      data = {};
      customerNameList = [];
      customerIdsList = [];
    });
    // var p = await getFieldsForCreatePurchaseInvoice();
    var p = await getFieldsForCreateQuotation();
    quotationNumber = p['quotationNumber'];
    if ('$p' != '[]') {
      setState(() {
        data.addAll(p);
        quotationNumber = p['quotationNumber'] as String;
        for (var client in p['clients']) {
          customerNameList.add('${client['name']}');
          customerIdsList.add('${client['id']}');
        }
        isPurchaseInvoicesInfoFetched = true;
      });
    }
  }

  @override
  void initState() {
    getFieldsForCreateQuotationFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isPurchaseInvoicesInfoFetched
        ? Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // PageTitle(text: 'create_new_client_order'.tr),
                PageTitle(text: 'Create New Purchase Invoice'),


              ],
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UnderTitleBtn(
                      text: 'preview'.tr,
                      onTap: () {
                        setState(() {
                          // progressVar+=1;
                        });
                      },
                    ),
                    UnderTitleBtn(
                      text: 'send_by_email'.tr,
                      onTap: () {
                        if (progressVar == 0) {
                          setState(() {
                            progressVar += 1;
                          });
                        }
                      },
                    ),
                    UnderTitleBtn(
                      text: 'confirm'.tr,
                      onTap: () {
                        if (progressVar == 1) {
                          setState(() {
                            progressVar += 1;
                          });
                        }
                      },
                    ),
                    UnderTitleBtn(
                      text: 'cancel'.tr,
                      onTap: () {
                        setState(() {
                          progressVar = 0;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    ReusableTimeLineTile(
                        id: 0,
                        progressVar: progressVar,
                        isFirst: true,
                        isLast: false,
                        isPast: true,
                        text: 'processing'.tr),
                    ReusableTimeLineTile(
                        id: 1,
                        progressVar: progressVar,
                        isFirst: false,
                        isLast: false,
                        isPast: false,
                        text: 'quotation_sent'.tr),
                    ReusableTimeLineTile(
                      id: 2,
                      progressVar: progressVar,
                      isFirst: false,
                      isLast: true,
                      isPast: false,
                      text: 'confirmed'.tr,
                    ),
                  ],
                )
              ],
            ),
            gapH16,
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Others.divider),
                  borderRadius:
                  const BorderRadius.all(Radius.circular(9))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [

                            const Text(
                              // '${data['supplierNumber'] ?? ''}',
                              "PI000001",
                              style: TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            ),

                            // isPurchaseInvoicesInfoFetched
                            //     ? Text(
                            //     quotationNumber, //'${data['quotationNumber'].toString() ?? ''}',
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 20,
                            //         color:
                            //         TypographyColor.titleTable))
                            //     : const CircularProgressIndicator(),


                            SizedBox(
                              width: MediaQuery.of(context).size.width *
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
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'customer_name'.tr}*'),
                            DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width *
                                  0.25,
                              // requestFocusOnTap: false,
                              enableSearch: true,
                              controller: searchController,
                              hintText: '${'search'.tr}...',
                              inputDecorationTheme:
                              InputDecorationTheme(
                                // filled: true,
                                hintStyle: const TextStyle(
                                    fontStyle: FontStyle.italic),
                                contentPadding:
                                const EdgeInsets.fromLTRB(
                                    20, 0, 25, 5),
                                // outlineBorder: BorderSide(color: Colors.black,),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Primary.primary
                                          .withAlpha((0.2 * 255).toInt()),
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Primary.primary
                                          .withAlpha((0.4 * 255).toInt()),
                                      width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                              ),
                              // menuStyle: ,
                              menuHeight: 250,
                              dropdownMenuEntries: customerNameList
                                  .map<DropdownMenuEntry<String>>(
                                      (String option) {
                                    return DropdownMenuEntry<String>(
                                      value: option,
                                      label: option,
                                    );
                                  }).toList(),
                              enableFilter: true,
                              onSelected: (String? val) {
                                setState(() {
                                  selectedItem = val!;
                                  var index =
                                  customerNameList.indexOf(val);
                                  selectedCustomerIds =
                                  customerIdsList[index];
                                });
                              },
                            ),
                          ],
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('contact_details'.tr),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('validity'.tr),
                              DialogDateTextField(
                                textEditingController:validityController ,
                                text: '',
                                textFieldWidth:
                                MediaQuery.of(context).size.width * 0.15,
                                validationFunc: (val) {},
                                onChangedFunc: (val){},
                                onDateSelected: (value) {
                                  validityController.text=value;
                                  setState(() {
                                    // LocalDate a=LocalDate.today();
                                    // LocalDate b = LocalDate.dateTime(value);
                                    // Period diff = b.periodSince(a);
                                    // print("years: ${diff.years}; months: ${diff.months}; days: ${diff.days}");
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        // DialogTextField(
                        //   textEditingController: validityController,
                        //   text: 'validity'.tr,
                        //   rowWidth:
                        //       MediaQuery.of(context).size.width * 0.25,
                        //   textFieldWidth:
                        //       MediaQuery.of(context).size.width * 0.15,
                        //   validationFunc: () {},
                        // ),
                        gapH16,
                        DialogDropMenu(
                          optionsList: ['cash'.tr, 'on_account'.tr],
                          text: 'payment_terms'.tr,
                          hint: 'cash'.tr,
                          rowWidth:
                          MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                          MediaQuery.of(context).size.width * 0.15,
                          onSelected: (value) {
                            setState(() {
                              selectedPaymentTerm = value;
                            });
                          },
                        ),
                        gapH16,
                        DialogDropMenu(
                          optionsList: ['standard'.tr],
                          text: 'price_list'.tr,
                          hint: 'standard'.tr,
                          rowWidth:
                          MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                          MediaQuery.of(context).size.width * 0.15,
                          onSelected: (value) {
                            setState(() {
                              selectedPriceList = value;
                            });
                          },
                        ),
                        gapH16,
                        DialogDropMenu(
                          optionsList: ['usd'.tr, 'lbp'.tr],
                          text: 'currency'.tr,
                          hint: 'usd'.tr,
                          rowWidth:
                          MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                          MediaQuery.of(context).size.width * 0.15,
                          onSelected: (value) {
                            setState(() {
                              selectedCurrency = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children: tabsList
                        .map((element) => _buildTabChipItem(
                        element,
                        // element['id'],
                        // element['name'],
                        tabsList.indexOf(element)))
                        .toList()),
              ],
            ),
            // tabsContent[selectedTabIndex],
            selectedTabIndex == 0
                ? Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                      MediaQuery.of(context).size.width *
                          0.01,
                      vertical: 15),
                  decoration: BoxDecoration(
                      color: Primary.primary,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(6))),
                  child: Row(
                    children: [
                      TableTitle(
                        text: 'item_code'.tr,
                        width: MediaQuery.of(context).size.width *
                            0.07,
                      ),
                      TableTitle(
                        text: 'description'.tr,
                        width: MediaQuery.of(context).size.width *
                            0.33,
                      ),
                      TableTitle(
                        text: 'quantity'.tr,
                        width: MediaQuery.of(context).size.width *
                            0.05,
                      ),
                      TableTitle(
                        text: 'unit_price'.tr,
                        width: MediaQuery.of(context).size.width *
                            0.05,
                      ),
                      TableTitle(
                        text: '${'disc'.tr}. %',
                        width: MediaQuery.of(context).size.width *
                            0.05,
                      ),
                      TableTitle(
                        text: 'total'.tr,
                        width: MediaQuery.of(context).size.width *
                            0.07,
                      ),
                      TableTitle(
                        text: '     ${'more_options'.tr}',
                        width: MediaQuery.of(context).size.width *
                            0.07,
                      ),
                    ],
                  ),
                ),
                GetBuilder<QuotationsController>(builder: (cont) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                        MediaQuery.of(context).size.width *
                            0.01),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6)),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: listViewLength,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            itemCount: cont.orderLinesList
                                .length, //products is data from back res
                            itemBuilder: (context, index) => Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin:
                                  const EdgeInsets.symmetric(
                                      vertical: 15),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/newRow.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                cont.orderLinesList[index],
                                SizedBox(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.03,
                                  child: const ReusableMore(
                                    itemsList: [],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.03,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        cont.removeFromOrderLinesList(
                                            index);
                                        listViewLength =
                                            listViewLength -
                                                increment;
                                      });
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
                        Row(
                          children: [
                            ReusableAddCard(
                              text: 'title'.tr,
                              onTap: () {
                                addNewTitle();
                              },
                            ),
                            gapW32,
                            ReusableAddCard(
                              text: 'item'.tr,
                              onTap: () {
                                addNewItem();
                              },
                            ),
                            gapW32,
                            ReusableAddCard(
                              text: 'combo'.tr,
                              onTap: () {
                                addNewCombo();
                              },
                            ),
                            gapW32,
                            ReusableAddCard(
                              text: 'image'.tr,
                              onTap: () {
                                addNewImage();
                              },
                            ),
                            gapW32,
                            ReusableAddCard(
                              text: 'note'.tr,
                              onTap: () {
                                addNewNote();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }),
                gapH24,
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'terms_conditions'.tr,
                        style: TextStyle(
                            fontSize: 15,
                            color: TypographyColor.titleTable,
                            fontWeight: FontWeight.bold),
                      ),
                      gapH16,
                      ReusableTextField(
                        textEditingController: controller,//todo
                        isPasswordField: false,
                        hint: 'terms_conditions'.tr,
                        onChangedFunc: (val) {},
                        validationFunc: (val) {
                          setState(() {
                            termsAndConditions = val;
                          });
                        },
                      ),
                      gapH16,
                      Text(
                        'or_create_new_terms_conditions'.tr,
                        style: TextStyle(
                            fontSize: 16,
                            color: Primary.primary,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 40),
                  decoration: BoxDecoration(
                    color: Primary.p20,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('total_before_vat'.tr),
                                Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.1,
                                  height: 47,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black
                                              .withAlpha((0.1 * 255).toInt()),
                                          width: 1),
                                      borderRadius:
                                      BorderRadius.circular(
                                          6)),
                                  child: const Center(
                                      child: Text('0')),
                                )
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('global_disc'.tr),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.1,
                                        child: ReusableTextField(
                                          textEditingController: globalDiscController,
                                          isPasswordField: false,
                                          hint: '0',
                                          onChangedFunc: (val) {
                                            setState(() {
                                              globalDisc = val;
                                            });
                                          },
                                          validationFunc: (val) {},
                                        )),
                                    gapW10,
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.1,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0')),
                                    )
                                  ],
                                )
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('special_disc'.tr),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.1,
                                        child: ReusableTextField(
                                          textEditingController: specialDiscController,
                                          isPasswordField: false,
                                          hint: '0',
                                          onChangedFunc: (val) {
                                            setState(() {
                                              specialDisc = val;
                                            });
                                          },
                                          validationFunc: (val) {},
                                        )),
                                    gapW10,
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.1,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0')),
                                    )
                                  ],
                                )
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('vat_11'.tr),
                                Row(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.1,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0')),
                                    ),
                                    gapW10,
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.1,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0.00')),
                                    )
                                  ],
                                )
                              ],
                            ),
                            gapH10,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total_amount'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Primary.primary,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                Text(
                                  '${'usd'.tr} 0.00',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Primary.primary,
                                      fontWeight:
                                      FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gapH28,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width *
                          0.15,
                      height: 45,
                      onTapFunction: () async {
                        var res = await oldStoreQuotation(
                            refController.text,
                            selectedCustomerIds,
                            validityController.text,
                            '',
                            '',
                            '',
                            termsAndConditions,
                            '',
                            '',
                            '',
                            commissionController.text,
                            totalCommissionController.text,
                            '',
                            specialDisc,
                            '',
                            globalDisc,
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            );
                        if (res['success'] == true) {
                          CommonWidgets.snackBar('Success',
                              res['message']);
                          setState(() {
                            isPurchaseInvoicesInfoFetched = false;
                            getFieldsForCreateQuotationFromBack();
                          });
                          homeController.selectedTab.value =
                          'quotation_summary';
                        } else {
                          CommonWidgets.snackBar('error',
                              res['message']);
                        }
                      },
                      // btnText: 'create_purchase_invoice'.tr,
                      btnText: 'Create Purchase Invoice',
                    ),
                  ],
                )
              ],
            )

                : Container(
              padding:  EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.35,
                      child: Column(
                        children: [
                          DialogDropMenu(
                            optionsList: const [''],
                            text: 'sales_person'.tr,
                            hint: 'search'.tr,
                            rowWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.3,
                            textFieldWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.15,
                            onSelected: () {},
                          ),
                          gapH16,
                          DialogDropMenu(
                            optionsList: const [''],
                            text: 'commission_method'.tr,
                            hint: '',
                            rowWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.3,
                            textFieldWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.15,
                            onSelected: () {},
                          ),
                          gapH16,
                          DialogDropMenu(
                            optionsList: ['cash'.tr],
                            text: 'cashing_method'.tr,
                            hint: '',
                            rowWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.3,
                            textFieldWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.15,
                            onSelected: () {},
                          ),
                        ],
                      )),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          DialogTextField(
                            textEditingController:
                            commissionController,
                            text: 'commission'.tr,
                            rowWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.3,
                            textFieldWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.15,
                            validationFunc: (val) {},
                          ),
                          gapH16,
                          DialogTextField(
                            textEditingController:
                            totalCommissionController,
                            text: 'total_commission'.tr,
                            rowWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.3,
                            textFieldWidth: MediaQuery.of(context)
                                .size
                                .width *
                                0.15,
                            validationFunc: (val) {},
                          ),
                        ],
                      )),
                ],
              ),
            ),
            gapH40,
          ],
        ),
      ),
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
                    topRight: Radius.circular(9)))),
        child: Container(
          width:name.length*10,// MediaQuery.of(context).size.width * 0.09,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
              color: selectedTabIndex == index ? Primary.p20 : Colors.white,
              border: selectedTabIndex == index
                  ? Border(
                top: BorderSide(color: Primary.primary, width: 3),
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  // offset: Offset(0, 3),
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
  }

  addNewTitle() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Widget p = Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: controller,//todo
        isPasswordField: false,
        hint: 'title'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    quotationController.addToOrderLinesList(p);
  }

  // String price='0',disc='0',result='0',quantity='0';
  addNewItem() {
    setState(() {
      listViewLength = listViewLength + increment;
    });

    Widget p = const ReusableItemRow();
    quotationController.addToOrderLinesList(p);
  }

  addNewCombo() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Widget p = const ReusableComboRow();
    quotationController.addToOrderLinesList(p);
  }

  addNewImage() {
    setState(() {
      listViewLength = listViewLength + 100;
    });
    Widget p = GetBuilder<QuotationsController>(builder: (cont) {
      return InkWell(
        onTap: () async {
          final image = await ImagePickerHelper.pickImage();
          setState(() {
        imageFile = image!;
            cont.changeBoolVar(true);
            cont.increaseImageSpace(90);
            listViewLength = listViewLength + (cont.imageSpaceHeight) + 10;
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
              height: cont.imageSpaceHeight,
              child: cont.imageAvailable
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.memory(
                    imageFile,
                    height: cont.imageSpaceHeight,
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gapW20,
                  Icon(Icons.cloud_upload_outlined,
                      color: Others.iconColor, size: 32),
                  gapW20,
                  Text(
                    'drag_drop_image'.tr,
                    style: TextStyle(color: TypographyColor.textTable),
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
    });
    quotationController.addToOrderLinesList(p);
  }

  addNewNote() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Widget p = Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: controller,//todo
        isPasswordField: false,
        hint: 'note'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    quotationController.addToOrderLinesList(p);
  }

  List<Step> getSteps() => [
    Step(
        title: const Text(''),
        content: Container(
          //page
        ),
        isActive: currentStep >= 0),
    Step(
        title: const Text(''),
        content: Container(),
        isActive: currentStep >= 1),
    Step(
        title: const Text(''),
        content: Container(),
        isActive: currentStep >= 2),
  ];
}

class UnderTitleBtn extends StatelessWidget {
  const UnderTitleBtn({super.key, required this.text, required this.onTap});
  final String text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin:  EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.009,
        ),
        decoration: BoxDecoration(
            color: Others.btnBg,
            borderRadius: const BorderRadius.all(Radius.circular(9))),
        child: Text(
          text,
          style: TextStyle(
            color: TypographyColor.titleTable,
          ),
        ),
      ),
    );
  }
}

class ReusableItemRow extends StatefulWidget {
  const ReusableItemRow({super.key});

  @override
  State<ReusableItemRow> createState() => _ReusableItemRowState();
}

class _ReusableItemRowState extends State<ReusableItemRow> {
  String price = '0', disc = '0', result = '0', quantity = '0';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DialogDropMenu(
            optionsList: const [''],
            text: '',
            hint: 'item'.tr,
            rowWidth: MediaQuery.of(context).size.width * 0.07,
            textFieldWidth: MediaQuery.of(context).size.width * 0.07,
            onSelected: () {},
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: ReusableTextField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: 'lorem ipsumlorem ipsum',
                onChangedFunc: (val) {},
                validationFunc: (val) {},
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: '1.00',
                onChangedFunc: (value) {
                  setState(() {
                    quantity = value;
                  });
                },
                validationFunc: (val) {},
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: '150.00',
                onChangedFunc: (val) {
                  setState(() {
                    price = val;
                  });
                },
                validationFunc: (val) {},
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: '15',
                onChangedFunc: (val) {
                  setState(() {
                    disc = val;
                  });
                },
                validationFunc: (val) {},
              )),
          Container(
            width: MediaQuery.of(context).size.width * 0.07,
            height: 47,
            decoration: BoxDecoration(
                border:
                Border.all(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
                borderRadius: BorderRadius.circular(6)),
            child: Center(
                child: Text(
                    '${int.parse(quantity) * (int.parse(price) - int.parse(disc))}')),
          ),
        ],
      ),
    );
  }
}

class ReusableComboRow extends StatefulWidget {
  const ReusableComboRow({super.key});

  @override
  State<ReusableComboRow> createState() => _ReusableComboRowState();
}

class _ReusableComboRowState extends State<ReusableComboRow> {
  String price = '0', disc = '0', result = '0', quantity = '0';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DialogDropMenu(
            optionsList: const [''],
            text: '',
            hint: 'combo'.tr,
            rowWidth: MediaQuery.of(context).size.width * 0.07,
            textFieldWidth: MediaQuery.of(context).size.width * 0.07,
            onSelected: () {},
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: 'lorem ipsumlorem ipsum',
                onChangedFunc: () {},
                validationFunc: (val) {},
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: '1.00',
                onChangedFunc: (value) {
                  setState(() {
                    quantity = value;
                  });
                },
                validationFunc: (val) {},
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: '150.00',
                onChangedFunc: (val) {
                  setState(() {
                    price = val;
                  });
                },
                validationFunc: (val) {},
              )),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: ReusableNumberField(
                textEditingController: controller,//todo
                isPasswordField: false,
                hint: '15',
                onChangedFunc: (val) {
                  setState(() {
                    disc = val;
                  });
                },
                validationFunc: (val) {},
              )),
          Container(
            width: MediaQuery.of(context).size.width * 0.07,
            height: 47,
            decoration: BoxDecoration(
                border:
                Border.all(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
                borderRadius: BorderRadius.circular(6)),
            child: Center(
                child: Text(
                    '${int.parse(quantity) * (int.parse(price) - int.parse(disc))}')),
          ),
        ],
      ),
    );
  }
}

class MobileCreateNewPurchaseInvoice extends StatefulWidget {
  const MobileCreateNewPurchaseInvoice({super.key});

  @override
  State<MobileCreateNewPurchaseInvoice> createState() =>
      _MobileCreateNewPurchaseInvoiceState();
}

class _MobileCreateNewPurchaseInvoiceState extends State<MobileCreateNewPurchaseInvoice> {
  // bool imageAvailable=false;
  GlobalKey accMoreKey2 = GlobalKey();
  TextEditingController commissionController = TextEditingController();
  TextEditingController totalCommissionController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController validityController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String
  selectedPaymentTerm = '',
      selectedPriceList = '',
      selectedCurrency = '',
      termsAndConditions = '',
      specialDisc = '',
      globalDisc = '';
  late Uint8List imageFile;

  int currentStep = 0;
  int selectedTabIndex = 0;
  GlobalKey accMoreKey = GlobalKey();
  List tabsList = [
    'order_lines',
    'other_information',
  ];
  String selectedTab = 'order_lines'.tr;
  String? selectedItem = '';

  double listViewLength = Sizes.deviceHeight * 0.08;
  double increment = Sizes.deviceHeight * 0.08;
  // double imageSpaceHeight = Sizes.deviceHeight * 0.1;
  // List<Widget> orderLinesList = [];
  final QuotationsController quotationController = Get.find();
  final HomeController homeController = Get.find();
  int progressVar = 0;
  Map data = {};
  bool isPurchaseInvoicesInfoFetched = false;
  List<String> customerNameList = [];
  List customerIdsList = [];
  String selectedCustomerIds = '';
  String quotationNumber = '';
  getFieldsForCreateQuotationFromBack() async {
    setState(() {
      selectedPaymentTerm = '';
      selectedPriceList = '';
      selectedCurrency = '';
      termsAndConditions = '';
      specialDisc = '';
      globalDisc = '';
      currentStep = 0;
      selectedTabIndex = 0;
      selectedItem = '';
      progressVar = 0;
      selectedCustomerIds = '';
      quotationNumber = '';
      data = {};
      customerNameList = [];
      customerIdsList = [];
    });
    var p = await getFieldsForCreateQuotation();
    quotationNumber = p['quotationNumber'];
    if ('$p' != '[]') {
      setState(() {
        data.addAll(p);
        quotationNumber = p['quotationNumber'] as String;
        for (var client in p['clients']) {
          customerNameList.add('${client['name']}');
          customerIdsList.add('${client['id']}');
        }
        isPurchaseInvoicesInfoFetched = true;
      });
    }
  }

  @override
  void initState() {
    getFieldsForCreateQuotationFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isPurchaseInvoicesInfoFetched
        ? Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // PageTitle(text: 'create_new_client_order'.tr),
                PageTitle(text: 'Create New Purchase Invoice'),
              ],
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UnderTitleBtn(
                  text: 'preview'.tr,
                  onTap: () {
                    setState(() {
                      // progressVar+=1;
                    });
                  },
                ),
                UnderTitleBtn(
                  text: 'send_by_email'.tr,
                  onTap: () {
                    if (progressVar == 0) {
                      setState(() {
                        progressVar += 1;
                      });
                    }
                  },
                ),
                UnderTitleBtn(
                  text: 'confirm'.tr,
                  onTap: () {
                    if (progressVar == 1) {
                      setState(() {
                        progressVar += 1;
                      });
                    }
                  },
                ),
                UnderTitleBtn(
                  text: 'cancel'.tr,
                  onTap: () {
                    setState(() {
                      progressVar = 0;
                    });
                  },
                ),
              ],
            ),
            gapH10,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ReusableTimeLineTile(
                    id: 0,
                    isDesktop: false,
                    progressVar: progressVar,
                    isFirst: true,
                    isLast: false,
                    isPast: true,
                    text: 'processing'.tr),
                ReusableTimeLineTile(
                    id: 1,
                    progressVar: progressVar,
                    isFirst: false,
                    isDesktop: false,
                    isLast: false,
                    isPast: false,
                    text: 'quotation_sent'.tr),
                ReusableTimeLineTile(
                  id: 2,
                  progressVar: progressVar,
                  isFirst: false,
                  isLast: true,
                  isDesktop: false,
                  isPast: false,
                  text: 'confirmed'.tr,
                ),
              ],
            ),
            gapH24,
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Others.divider),
                  borderRadius:
                  const BorderRadius.all(Radius.circular(9))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isPurchaseInvoicesInfoFetched
                      ? Text(
                      quotationNumber, //'${data['quotationNumber'].toString() ?? ''}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: TypographyColor.titleTable))
                      : const CircularProgressIndicator(),


                  gapH16,
                  DialogTextField(
                    textEditingController: refController,
                    text: '${'ref'.tr}:',
                    hint: 'manual_reference'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.5,
                    validationFunc: (val) {},
                  ),
                  gapH16,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'customer_name'.tr}*'),
                        DropdownMenu<String>(
                          width:
                          MediaQuery.of(context).size.width * 0.5,
                          // requestFocusOnTap: false,
                          enableSearch: true,
                          controller: searchController,
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
                                  color:
                                  Primary.primary.withAlpha((0.2 * 255).toInt()),
                                  width: 1),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                  Primary.primary.withAlpha((0.4 * 255).toInt()),
                                  width: 2),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(9)),
                            ),
                          ),
                          // menuStyle: ,
                          menuHeight: 250,
                          dropdownMenuEntries: customerNameList
                              .map<DropdownMenuEntry<String>>(
                                  (String option) {
                                return DropdownMenuEntry<String>(
                                  value: option,
                                  label: option,
                                );
                              }).toList(),
                          enableFilter: true,
                          onSelected: (String? val) {
                            setState(() {
                              selectedItem = val!;
                              var index = customerNameList.indexOf(val);
                              selectedCustomerIds =
                              customerIdsList[index];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  gapH16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('contact_details'.tr),
                    ],
                  ),
                  gapH16,
                  DialogTextField(
                    textEditingController: validityController,
                    text: 'validity'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.5,
                    validationFunc: (val) {},
                  ),
                  gapH16,
                  DialogDropMenu(
                    optionsList: ['cash'.tr, 'on_account'.tr],
                    text: 'payment_terms'.tr,
                    hint: 'cash'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.5,
                    onSelected: (value) {
                      setState(() {
                        selectedPaymentTerm = value;
                      });
                    },
                  ),
                  gapH16,
                  DialogDropMenu(
                    optionsList: ['standard'.tr],
                    text: 'price_list'.tr,
                    hint: 'standard'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.5,
                    onSelected: (value) {
                      setState(() {
                        selectedPriceList = value;
                      });
                    },
                  ),
                  gapH16,
                  DialogDropMenu(
                    optionsList: ['usd'.tr, 'lbp'.tr],
                    text: 'currency'.tr,
                    hint: 'usd'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.5,
                    onSelected: (value) {
                      setState(() {
                        selectedCurrency = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Container(
            //   padding:
            //   const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            //   decoration: BoxDecoration(
            //       border: Border.all(color: Others.divider),
            //       borderRadius: const BorderRadius.all(Radius.circular(9))),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //
            //       SizedBox(
            //         width: MediaQuery.of(context).size.width * 0.3,
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             // SizedBox(
            //             //   width: MediaQuery.of(context).size.width * 0.25,
            //             //   child: Row(
            //             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             //     children: [
            //             //       Text('validity'.tr),
            //             //       DialogDateTextField(
            //             //         text: '',
            //             //         textFieldWidth:
            //             //             MediaQuery.of(context).size.width * 0.15,
            //             //         validationFunc: () {},
            //             //         onChangedFunc: (value) {
            //             //           setState(() {
            //             //             validity=value;
            //             //           });
            //             //         },
            //             //       ),
            //             //     ],
            //             //   ),
            //             // ),
            //
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children: tabsList
                        .map((element) => _buildTabChipItem(
                        element,
                        // element['id'],
                        // element['name'],
                        tabsList.indexOf(element)))
                        .toList()),
              ],
            ),
            // tabsContent[selectedTabIndex],
            selectedTabIndex == 0
                ? Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: listViewLength + 100,
                  child: ListView(
                    // physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        height: listViewLength + 100,
                        width: MediaQuery.of(context).size.width ,
                        child: ListView(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.01,
                                  vertical: 15),
                              decoration: BoxDecoration(
                                  color: Primary.primary,
                                  borderRadius:
                                  const BorderRadius.all(
                                      Radius.circular(6))),
                              child: Row(
                                children: [
                                  TableTitle(
                                    text: 'item_code'.tr,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.15,
                                  ),
                                  TableTitle(
                                    text: 'description'.tr,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.5,
                                  ),
                                  TableTitle(
                                    text: 'quantity'.tr,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.15,
                                  ),
                                  TableTitle(
                                    text: 'unit_price'.tr,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.15,
                                  ),
                                  TableTitle(
                                    text: '${'disc'.tr}. %',
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.15,
                                  ),
                                  TableTitle(
                                    text: 'total'.tr,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.15,
                                  ),
                                  TableTitle(
                                    text:
                                    '     ${'more_options'.tr}',
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.15,
                                  ),
                                ],
                              ),
                            ),
                            GetBuilder<QuotationsController>(
                                builder: (cont) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.01),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft:
                                          Radius.circular(6),
                                          bottomRight:
                                          Radius.circular(6)),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: listViewLength,
                                          child: ListView.builder(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical: 10),
                                            itemCount: cont
                                                .orderLinesList
                                                .length, //products is data from back res
                                            itemBuilder:
                                                (context, index) =>
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      margin:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical:
                                                          15),
                                                      decoration:
                                                      const BoxDecoration(
                                                        image:
                                                        DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/newRow.png'),
                                                          fit: BoxFit
                                                              .contain,
                                                        ),
                                                      ),
                                                    ),
                                                    cont.orderLinesList[
                                                    index],
                                                    SizedBox(
                                                      width: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width *
                                                          0.03,
                                                      child:
                                                      const ReusableMore(
                                                        itemsList: [],),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width *
                                                          0.03,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            cont.removeFromOrderLinesList(
                                                                index);
                                                            listViewLength =
                                                                listViewLength -
                                                                    increment;
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .delete_outline,
                                                          color: Primary
                                                              .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            ReusableAddCard(
                                              text: 'title'.tr,
                                              onTap: () {
                                                addNewTitle();
                                              },
                                            ),
                                            gapW32,
                                            ReusableAddCard(
                                              text: 'item'.tr,
                                              onTap: () {
                                                addNewItem();
                                              },
                                            ),
                                            gapW32,
                                            ReusableAddCard(
                                              text: 'combo'.tr,
                                              onTap: () {
                                                addNewCombo();
                                              },
                                            ),
                                            gapW32,
                                            ReusableAddCard(
                                              text: 'image'.tr,
                                              onTap: () {
                                                addNewImage();
                                              },
                                            ),
                                            gapW32,
                                            ReusableAddCard(
                                              text: 'note'.tr,
                                              onTap: () {
                                                addNewNote();
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gapH24,
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'terms_conditions'.tr,
                        style: TextStyle(
                            fontSize: 15,
                            color: TypographyColor.titleTable,
                            fontWeight: FontWeight.bold),
                      ),
                      gapH16,
                      ReusableTextField(
                        textEditingController: controller,//todo
                        isPasswordField: false,
                        hint: 'terms_conditions'.tr,
                        onChangedFunc: () {},
                        validationFunc: (val) {
                          setState(() {
                            termsAndConditions = val;
                          });
                        },
                      ),
                      gapH16,
                      Text(
                        'or_create_new_terms_conditions'.tr,
                        style: TextStyle(
                            fontSize: 16,
                            color: Primary.primary,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Primary.p20,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.8,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('total_before_vat'.tr),
                                Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.2,
                                  height: 47,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black
                                              .withAlpha((0.1 * 255).toInt()),
                                          width: 1),
                                      borderRadius:
                                      BorderRadius.circular(
                                          6)),
                                  child: const Center(
                                      child: Text('0')),
                                )
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('global_disc'.tr),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.2,
                                        child: ReusableTextField(
                                          textEditingController: controller,//todo
                                          isPasswordField: false,
                                          hint: '0',
                                          onChangedFunc: (val) {
                                            setState(() {
                                              globalDisc = val;
                                            });
                                          },
                                          validationFunc: (val) {},
                                        )),
                                    gapW10,
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.2,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0')),
                                    )
                                  ],
                                )
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('special_disc'.tr),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.2,
                                        child: ReusableTextField(
                                          textEditingController: controller,//todo
                                          isPasswordField: false,
                                          hint: '0',
                                          onChangedFunc: (val) {
                                            setState(() {
                                              specialDisc = val;
                                            });
                                          },
                                          validationFunc: (val) {},
                                        )),
                                    gapW10,
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.2,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0')),
                                    )
                                  ],
                                )
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('vat_11'.tr),
                                Row(
                                  children: [
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.2,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0')),
                                    ),
                                    gapW10,
                                    Container(
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.2,
                                      height: 47,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                          BorderRadius
                                              .circular(6)),
                                      child: const Center(
                                          child: Text('0.00')),
                                    )
                                  ],
                                )
                              ],
                            ),
                            gapH10,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total_amount'.tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Primary.primary,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                Text(
                                  '${'usd'.tr} 0.00',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Primary.primary,
                                      fontWeight:
                                      FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gapH28,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ReusableButtonWithColor(
                      width:
                      MediaQuery.of(context).size.width * 0.3,
                      height: 45,
                      onTapFunction: () async {
                        var res = await oldStoreQuotation(
                            refController.text,
                            selectedCustomerIds,
                            validityController.text,
                            '',
                            '',
                            '',
                            termsAndConditions,
                            '',
                            '',
                            '',
                            commissionController.text,
                            totalCommissionController.text,
                            '',
                            specialDisc,
                            '',
                            globalDisc,
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            );
                        if (res['success'] == true) {
                          CommonWidgets.snackBar('Success',
                              res['message']);
                          setState(() {
                            isPurchaseInvoicesInfoFetched = false;
                            getFieldsForCreateQuotationFromBack();
                          });
                          homeController.selectedTab.value =
                          'quotation_summary';
                        } else {
                          CommonWidgets.snackBar('error',
                              res['message']);
                        }
                      },
                      // btnText: 'create_purchase_invoice'.tr,
                      btnText: 'Create Purchase Invoice',
                    ),
                  ],
                )
              ],
            )
                : Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  DialogDropMenu(
                    optionsList: const [''],
                    text: 'sales_person'.tr,
                    hint: 'search'.tr,
                    rowWidth:
                    MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.4,
                    onSelected: () {},
                  ),
                  gapH16,
                  DialogDropMenu(
                    optionsList: const [''],
                    text: 'commission_method'.tr,
                    hint: '',
                    rowWidth:
                    MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.4,
                    onSelected: () {},
                  ),
                  gapH16,
                  DialogDropMenu(
                    optionsList: ['cash'.tr],
                    text: 'cashing_method'.tr,
                    hint: '',
                    rowWidth:
                    MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.4,
                    onSelected: () {},
                  ),
                  gapH16,
                  DialogTextField(
                    textEditingController: commissionController,
                    text: 'commission'.tr,
                    rowWidth:
                    MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.4,
                    validationFunc: (val) {},
                  ),
                  gapH16,
                  DialogTextField(
                    textEditingController:
                    totalCommissionController,
                    text: 'total_commission'.tr,
                    rowWidth:
                    MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth:
                    MediaQuery.of(context).size.width * 0.4,
                    validationFunc: (val) {},
                  ),
                ],
              ),
            ),
            gapH40,
          ],
        ),
      ),
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
                    topRight: Radius.circular(9)))),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
              color: selectedTabIndex == index ? Primary.p20 : Colors.white,
              border: selectedTabIndex == index
                  ? Border(
                top: BorderSide(color: Primary.primary, width: 3),
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  // offset: const Offset(0, 3),
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
  }

  addNewTitle() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Widget p = Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: controller,//todo
        isPasswordField: false,
        hint: 'title'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    quotationController.addToOrderLinesList(p);
  }

  // String price='0',disc='0',result='0',quantity='0';
  addNewItem() {
    setState(() {
      listViewLength = listViewLength + increment;
    });

    Widget p = const ReusableItemRow();
    quotationController.addToOrderLinesList(p);
  }

  addNewCombo() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Widget p = const ReusableComboRow();
    quotationController.addToOrderLinesList(p);
  }

  addNewImage() {
    setState(() {
      listViewLength = listViewLength + 100;
    });
    Widget p = GetBuilder<QuotationsController>(builder: (cont) {
      return InkWell(
        onTap: () async {
          final image = await ImagePickerHelper.pickImage();
          setState(() {
        imageFile = image!;
            cont.changeBoolVar(true);
            cont.increaseImageSpace(90);
            listViewLength = listViewLength + (cont.imageSpaceHeight) + 10;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: DottedBorder(
            dashPattern: const [10, 10],
            color: Others.borderColor,
            radius: const Radius.circular(9),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.63,
              height: cont.imageSpaceHeight,
              child: cont.imageAvailable
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.memory(
                    imageFile,
                    height: cont.imageSpaceHeight,
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gapW20,
                  Icon(Icons.cloud_upload_outlined,
                      color: Others.iconColor, size: 32),
                  gapW20,
                  Text(
                    'drag_drop_image'.tr,
                    style: TextStyle(color: TypographyColor.textTable),
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
    });
    quotationController.addToOrderLinesList(p);
  }

  addNewNote() {
    setState(() {
      listViewLength = listViewLength + increment;
    });
    Widget p = Container(
      width: MediaQuery.of(context).size.width * 0.63,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ReusableTextField(
        textEditingController: controller,//todo
        isPasswordField: false,
        hint: 'note'.tr,
        onChangedFunc: (val) {},
        validationFunc: (val) {},
      ),
    );
    quotationController.addToOrderLinesList(p);
  }

  List<Step> getSteps() => [
    Step(
        title: const Text(''),
        content: Container(
          //page
        ),
        isActive: currentStep >= 0),
    Step(
        title: const Text(''),
        content: Container(),
        isActive: currentStep >= 1),
    Step(
        title: const Text(''),
        content: Container(),
        isActive: currentStep >= 2),
  ];
}
