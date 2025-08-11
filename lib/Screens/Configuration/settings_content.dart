import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/CompanySettings/update_settings.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/settings_controller.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Controllers/company_settings_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/add_photo_circle.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading_dialog.dart';
import '../../Widgets/reusable_btn.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';

import '../../Widgets/reusable_photo_card_in_update_product.dart';
import '../../Widgets/reusable_text_field.dart';

List costOptionsList = [
  'Weighted Average Cost (WAC)',
  'First-In, First-Out (FIFO)',
  'Last-In, First-Out (LIFO)',
  'Specific Identification',
  'Standard Costing',
];

List costOptionsCutsList = ['WAC', 'FIFO', 'LIFO', 'SI', 'SC'];

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  int selectedTabIndex = 0;
  List tabsList = ['cost_options', 'pos_options', 'company_settings', 'header'];

  List tabsContent = [
    const CostOptionsTab(),
    const PosOptionsTab(),
    const CompanySettingsTab(),
    const HeaderTab(),
  ];
  CompanySettingsController companySettingsController = Get.find();
  HomeController homeController = Get.find();
  ExchangeRatesController exchangeRatesController = Get.find();
  QuotationController quotationController = Get.find();
  getInfoFromPref() async {
    var selectedCost = await getCostCalculationTypeFromPref();
    var showQuantitiesOnPos = await getShowQuantitiesOnPosFromPref();
    var showLogoOnPos = await getShowLogoOnPosFromPref();
    var fullCompanyName = await getFullCompanyNameFromPref();
    var headerName = await getHeaderNameFromPref();
    var companyEmail = await getCompanyEmailFromPref();
    var companyPhone = await getCompanyPhoneNumberFromPref();
    var companyMobile = await getCompanyMobileNumberFromPref();
    var companyPhoneCode = await getCompanyPhoneCodeFromPref();
    var companyMobileCode = await getCompanyMobileCodeFromPref();
    // var company = await getCompanyMobileNumberFromPref();
    var companyVat = await getCompanyVatFromPref();
    var companyLogo = await getCompanyLogoFromPref();
    var companyTrn = await getCompanyTrnFromPref();
    var companyBankInfo = await getCompanyBankInfoFromPref();
    var companyAddress = await getCompanyAddressFromPref();
    var localPayments = await getCompanyLocalPaymentsFromPref();
    var primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
    var primaryCurrencyId = await getCompanyPrimaryCurrencyIdFromPref();
    var primaryCurrencySymbol = await getCompanyPrimaryCurrencySymbolFromPref();
    var posCurrency = await getCompanyPosCurrencyFromPref();
    var posCurrencyId = await getCompanyPosCurrencyIdFromPref();
    var posCurrencySymbol = await getCompanyPosCurrencySymbolFromPref();
    var companySubjectToVat = await getCompanySubjectToVatFromPref();
    if (selectedCost == '') {
      companySettingsController.setSelectedCostOption(1);
    } else {
      companySettingsController.setSelectedCostOption(
        1 + costOptionsCutsList.indexOf(selectedCost),
      );
    }
    if (showQuantitiesOnPos == '') {
      companySettingsController.setIsShowQuantitiesOnPosChecked(false);
    } else {
      companySettingsController.setIsShowQuantitiesOnPosChecked(
        showQuantitiesOnPos == '1' ? true : false,
      );
    }
    if (showLogoOnPos == '') {
      companySettingsController.setIsShowLogoOnPosChecked(false);
    } else {
      companySettingsController.setIsShowLogoOnPosChecked(
        showLogoOnPos == '1' ? true : false,
      );
    }
    companySettingsController.selectedPhoneCode = companyPhoneCode;
    companySettingsController.selectedMobileCode = companyMobileCode;
    companySettingsController.fullCompanyName.text = fullCompanyName;
    companySettingsController.headerName.text = headerName;
    companySettingsController.email.text = companyEmail;
    companySettingsController.phone.text = companyPhone;
    companySettingsController.mobile.text = companyMobile;
    companySettingsController.vat.text = companyVat;
    companySettingsController.logo = companyLogo;
    companySettingsController.trn.text = companyTrn;
    companySettingsController.bankInformation.text = companyBankInfo;
    companySettingsController.address.text = companyAddress;
    companySettingsController.localPayments.text = localPayments;
    companySettingsController.primaryCurrency.text = primaryCurrency;
    companySettingsController.selectedCurrencyId = primaryCurrencyId;
    companySettingsController.selectedCurrencySymbol = primaryCurrencySymbol;
    companySettingsController.posCurrency.text = posCurrency;
    companySettingsController.selectedPosCurrencyId = posCurrencyId;
    companySettingsController.selectedPosCurrencySymbol = posCurrencySymbol;
    companySettingsController.isCompanySubjectToVat =
        companySubjectToVat == '1' ? true : false;
    if (posCurrency.isNotEmpty) {
      companySettingsController.isPosCurrencyFound = true;
    }
  }

  @override
  void initState() {
    getInfoFromPref();
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: EdgeInsets.symmetric(
        horizontal: homeController.isMobile.value ? 10 : 50,
        vertical: 15,
      ),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTitle(text: 'settings'.tr),
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
                            isMobile: homeController.isMobile.value,
                            name: element,
                            index: tabsList.indexOf(element),
                            function: () {
                              setState(() {
                                selectedTabIndex = tabsList.indexOf(element);
                              });
                            },
                            isClicked:
                                selectedTabIndex == tabsList.indexOf(element),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
          tabsContent[selectedTabIndex],
          const Spacer(),
          GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // cont.setSelectedCostOption(1);
                      // cont.setIsShowQuantitiesOnPosChecked(false);
                      getInfoFromPref();
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
                      //todo check if header empty*********************************
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
                      var companyId = await getCompanyIdFromPref();
                      var res = await updateSettings(
                        companyId: companyId,
                        costCalculationType:
                            costOptionsCutsList[cont.selectedCostOption - 1],
                        showQuantitiesOnPos:
                            cont.isShowQuantitiesOnPosChecked ? '1' : '0',
                        selectedPhoneCode: cont.selectedPhoneCode,
                        selectedMobileCode: cont.selectedMobileCode,
                        companyName: cont.fullCompanyName.text,
                        address: cont.address.text,
                        mobile: cont.mobile.text,
                        phone: cont.phone.text,
                        email: cont.email.text,
                        trn: cont.trn.text,
                        bankInformation: cont.bankInformation.text,
                        localPayments: cont.localPayments.text,
                        vat: cont.vat.text.replaceAll(',', ''),
                        imageFile: cont.imageFile,
                        primaryCurrencyId: cont.selectedCurrencyId,
                        companySubjectToVat:
                            cont.isCompanySubjectToVat ? '1' : '0',
                        posCurrencyId: cont.selectedPosCurrencyId,
                        showLogoOnPos: cont.isShowLogoOnPosChecked ? '1' : '0',
                        headerName: cont.headerName.text,
                      );
                      Get.back();
                      if (res['success'] == true) {
                        Get.back();
                        CommonWidgets.snackBar('Success', res['message']);
                        await saveCompanySettingsLocally(
                          costOptionsCutsList[cont.selectedCostOption - 1],
                          cont.isShowQuantitiesOnPosChecked ? '1' : '0',
                          res['data']['logo'],
                          cont.fullCompanyName.text,
                          cont.email.text,
                          cont.vat.text,
                          cont.mobile.text,
                          cont.phone.text,
                          cont.trn.text,
                          cont.bankInformation.text,
                          cont.address.text,
                          cont.selectedPhoneCode,
                          cont.selectedMobileCode,
                          cont.localPayments.text,
                          cont.primaryCurrency.text,
                          cont.selectedCurrencyId,
                          cont.selectedCurrencySymbol,
                          cont.isCompanySubjectToVat == true ? '1' : '0',
                          cont.posCurrency.text,
                          cont.selectedPosCurrencyId,
                          cont.selectedPosCurrencySymbol,
                          res['data']['primaryCurrency']['latest_rate'],
                          res['data']['posCurrency'] == null
                              ? ''
                              : res['data']['posCurrency']['latest_rate'],
                          cont.isShowLogoOnPosChecked ? '1' : '0',
                          cont.headerName.text,
                        );
                        quotationController.setIsVatExemptCheckBoxShouldAppear(
                          cont.isCompanySubjectToVat,
                        );
                        quotationController.setIsVatExempted(
                          false,
                          false,
                          !cont.isCompanySubjectToVat,
                        );
                        quotationController.setIsVatExemptChecked(
                          !cont.isCompanySubjectToVat,
                        );
                      } else {
                        CommonWidgets.snackBar(
                          'error',
                          res['message'] ?? 'error'.tr,
                        );
                      }
                    },
                    width: 100,
                    height: 35,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  //companyId,
  //                         costOptionsCutsList[cont.selectedCostOption-1],
  //                         cont.isShowQuantitiesOnPosChecked?'1':'0'
}

class CostOptionsTab extends StatefulWidget {
  const CostOptionsTab({super.key});

  @override
  State<CostOptionsTab> createState() => _CostOptionsTabState();
}

class _CostOptionsTabState extends State<CostOptionsTab> {
  final HomeController homeController = Get.find();
  final SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH32,
          GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return Expanded(
                child: ListView.builder(
                  itemCount: costOptionsList.length,
                  itemBuilder:
                      (context, index) => ListTile(
                        title: Text(
                          costOptionsList[index],
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: Radio(
                          value: index + 1,
                          groupValue: cont.selectedCostOption,
                          onChanged: (value) {
                            cont.setSelectedCostOption(value!);
                          },
                        ),
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PosOptionsTab extends StatefulWidget {
  const PosOptionsTab({super.key});

  @override
  State<PosOptionsTab> createState() => _PosOptionsTabState();
}

class _PosOptionsTabState extends State<PosOptionsTab> {
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.65,
      child: GetBuilder<CompanySettingsController>(
        builder: (cont) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH32,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: cont.isShowQuantitiesOnPosChecked,
                    onChanged: (bool? value) {
                      cont.setIsShowQuantitiesOnPosChecked(value!);
                    },
                  ),
                  gapW4,
                  Text(
                    'show_quantities_in_pos'.tr,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              gapH16,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: cont.isShowLogoOnPosChecked,
                    onChanged: (bool? value) {
                      cont.setIsShowLogoOnPosChecked(value!);
                    },
                  ),
                  gapW4,
                  Text(
                    'show_Logo_in_pos'.tr,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              gapH16,
              Row(
                children: [
                  SizedBox(
                    width:
                        homeController.isMobile.value
                            ? MediaQuery.of(context).size.width * 0.22
                            : MediaQuery.of(context).size.width * 0.1,
                    child: Text('pos_currency'.tr),
                  ),
                  cont.isPosCurrencyFound
                      ? ReusableShowInfoCard(
                        text: cont.posCurrency.text,
                        width: MediaQuery.of(context).size.width * 0.4,
                      )
                      : GetBuilder<ExchangeRatesController>(
                        builder: (exchangeRatesCont) {
                          return DropdownMenu<String>(
                            width:
                                homeController.isMobile.value
                                    ? MediaQuery.of(context).size.width * 0.4
                                    : MediaQuery.of(context).size.width * 0.25,
                            enableSearch: true,
                            controller: cont.posCurrency,
                            hintText: '',
                            inputDecorationTheme: InputDecorationTheme(
                              hintStyle: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                25,
                                5,
                              ),
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
                            menuHeight: 250,
                            dropdownMenuEntries:
                                exchangeRatesCont.currenciesNamesList
                                    .map<DropdownMenuEntry<String>>((
                                      String option,
                                    ) {
                                      return DropdownMenuEntry<String>(
                                        value: option,
                                        label: option,
                                      );
                                    })
                                    .toList(),
                            enableFilter: true,
                            onSelected: (val) {
                              var index = exchangeRatesCont.currenciesNamesList
                                  .indexOf(val!);
                              cont.setSelectedPosCurrency(
                                exchangeRatesCont.currenciesIdsList[index],
                                val,
                                exchangeRatesCont.currenciesSymbolsList[index],
                              );
                            },
                          );
                        },
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

class CompanySettingsTab extends StatefulWidget {
  const CompanySettingsTab({super.key});

  @override
  State<CompanySettingsTab> createState() => _CompanySettingsTabState();
}

class _CompanySettingsTabState extends State<CompanySettingsTab> {
  HomeController homeController = Get.find();
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return homeController.isMobile.value
        ? Container(
          color: Colors.white,
          // width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.65,
          child: GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gapH32,
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.32,
                          child: Text('primary_currency'.tr),
                        ),
                        ReusableShowInfoCard(
                          text: cont.primaryCurrency.text,
                          width: MediaQuery.of(context).size.width * 0.4,
                        ),
                        // GetBuilder<ExchangeRatesController>(
                        //   builder: (exchangeRatesCont) {
                        //     return DropdownMenu<String>(
                        //       width: MediaQuery.of(context).size.width * 0.4,
                        //       // requestFocusOnTap: false,
                        //       enableSearch: true,
                        //       controller: cont.primaryCurrency,
                        //       hintText: '',
                        //       inputDecorationTheme: InputDecorationTheme(
                        //         // filled: true,
                        //         hintStyle: const TextStyle(
                        //           fontStyle: FontStyle.italic,
                        //         ),
                        //         contentPadding: const EdgeInsets.fromLTRB(
                        //           20,
                        //           0,
                        //           25,
                        //           5,
                        //         ),
                        //         // outlineBorder: BorderSide(color: Colors.black,),
                        //         enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //             color: Primary.primary.withAlpha(
                        //               (0.2 * 255).toInt(),
                        //             ),
                        //             width: 1,
                        //           ),
                        //           borderRadius: const BorderRadius.all(
                        //             Radius.circular(9),
                        //           ),
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //             color: Primary.primary.withAlpha(
                        //               (0.4 * 255).toInt(),
                        //             ),
                        //             width: 2,
                        //           ),
                        //           borderRadius: const BorderRadius.all(
                        //             Radius.circular(9),
                        //           ),
                        //         ),
                        //       ),
                        //       // menuStyle: ,
                        //       menuHeight: 250,
                        //       dropdownMenuEntries:
                        //           exchangeRatesCont.currenciesNamesList
                        //               .map<DropdownMenuEntry<String>>((
                        //                 String option,
                        //               ) {
                        //                 return DropdownMenuEntry<String>(
                        //                   value: option,
                        //                   label: option,
                        //                 );
                        //               })
                        //               .toList(),
                        //       enableFilter: true,
                        //       onSelected: (val) {
                        //         var index = exchangeRatesCont
                        //             .currenciesNamesList
                        //             .indexOf(val!);
                        //         cont.setSelectedCurrency(
                        //           exchangeRatesCont.currenciesIdsList[index],
                        //           val,
                        //           exchangeRatesCont
                        //               .currenciesSymbolsList[index],
                        //         );
                        //         var result = exchangeRatesCont.exchangeRatesList
                        //             .firstWhere(
                        //               (item) => item["currency"] == val,
                        //               orElse: () => null,
                        //             );
                        //         cont.setExchangeRateForSelectedCurrency(
                        //           result != null
                        //               ? '${result["exchange_rate"]}'
                        //               : '1',
                        //         );
                        //       },
                        //     );
                        //
                        //     // ReusableDropDownMenuWithSearch(
                        //     //   list: exchangeRatesCont.currenciesNamesList,
                        //     //   text: 'primary_currency'.tr,
                        //     //   hint: '',
                        //     //   onSelected: (val){
                        //     //     var index = exchangeRatesCont
                        //     //         .currenciesNamesList
                        //     //         .indexOf(val!);
                        //     //     cont.setSelectedCurrency(
                        //     //       exchangeRatesCont.currenciesIdsList[index],
                        //     //       val,
                        //     //     );
                        //     //     var result = exchangeRatesCont
                        //     //         .exchangeRatesList
                        //     //         .firstWhere(
                        //     //           (item) =>
                        //     //       item["currency"] == val,
                        //     //       orElse: () => null,
                        //     //     );
                        //     //     cont
                        //     //         .setExchangeRateForSelectedCurrency(
                        //     //       result != null
                        //     //           ? '${result["exchange_rate"]}'
                        //     //           : '1',
                        //     //     );
                        //     //   },
                        //     //   controller: cont.primaryCurrency,
                        //     //   validationFunc: (value) {
                        //     //     return null;
                        //     //   },
                        //     //   rowWidth: MediaQuery.of(context).size.width * 0.35,
                        //     //   textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                        //     //   clickableOptionText: '',
                        //     //   isThereClickableOption: false,
                        //     //   onTappedClickableOption: (){});
                        //   },
                        // ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        )
        : Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.65,
          child: GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return RawScrollbar(
                controller: scrollController,
                thumbVisibility: true,
                thickness: 8,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gapH32,
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.10,
                            child: Text('primary_currency'.tr),
                          ),
                          ReusableShowInfoCard(
                            text: cont.primaryCurrency.text,
                            width: MediaQuery.of(context).size.width * 0.25,
                            isCentered: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }
}

class HeaderTab extends StatefulWidget {
  const HeaderTab({super.key});

  @override
  State<HeaderTab> createState() => _HeaderTabState();
}

class _HeaderTabState extends State<HeaderTab> {
  CompanySettingsController companySettingsController = Get.find();
  HomeController homeController = Get.find();
  addNewHeader() {
    Map header = {
      'logo':'',
      'fullCompanyName': '',
      'companyEmail': '',
      'vat': '',
      'trn': '',
      'bankInfo': '',
      'phoneCode': '+961',
      'phoneNumber': '',
      'mobileCode': '+961',
      'mobileNumber': '',
      'address': '',
      'localPayments': '',
      'companySubjectToVat': '',
      'headerName': '',
    };
    companySettingsController.addToHeadersList(header);
  }

  @override
  Widget build(BuildContext context) {
    return
      // homeController.companyName == 'CASALAGO'
      //   ? GetBuilder<CompanySettingsController>(
      //     builder: (cont) {
      //       return Column(
      //         children: [
      //           SizedBox(
      //             // height: cont.headersList.isEmpty?20:420,
      //             height: MediaQuery.of(context).size.height * 0.65,
      //             child: ListView.builder(
      //               itemCount: cont.headersList.length,
      //               itemBuilder:
      //                   (context, index) => ReusableCASALAGOHeaderSection(index: index),
      //             ),
      //           ),
      //           gapH16,
      //           ReusableAddCard(
      //             text: 'add_new_header'.tr,
      //             onTap: () {
      //               addNewHeader();
      //             },
      //           ),
      //         ],
      //       );
      //     },
      //   )
      //   :
    Container(
          color:
              Colors.white, // width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.65,
          child: ReusableHeaderSection(),
        );
  }
}

class ReusableHeaderSection extends StatefulWidget {
  const ReusableHeaderSection({super.key,});
  @override
  State<ReusableHeaderSection> createState() => _ReusableHeaderSectionState();
}

class _ReusableHeaderSectionState extends State<ReusableHeaderSection> {
  HomeController homeController = Get.find();
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return homeController.isMobile.value
        ? Container(
          decoration:
              homeController.companyName == 'CASALAGO'
                  ? BoxDecoration(

                    border: Border.all(
                      color: Primary.black.withAlpha((0.2 * 255).toInt()),
                    ),
                    borderRadius: BorderRadius.circular(9),
                  )
                  : BoxDecoration(
                    color:
                        Colors
                            .white,
                  ),
          // height: MediaQuery.of(context).size.height * 0.65,
          child: GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gapH32,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        cont.imageFile != null
                            ? InkWell(
                              onTap: () async {
                                final image =
                                    await ImagePickerHelper.pickImage();
                                cont.setImageFile(image!);
                              },
                              child: ReusablePhotoCircle(
                                imageFilePassed: cont.imageFile!,
                              ),
                            )
                            : cont.logo.isNotEmpty
                            ? InkWell(
                              onTap: () async {
                                final image =
                                    await ImagePickerHelper.pickImage();
                                cont.setImageFile(image!);
                              },
                              child: ReusablePhotoCard(url: cont.logo),
                            )
                            : ReusableAddPhotoCircle(
                              onTapCircle: () async {
                                final image =
                                    await ImagePickerHelper.pickImage();
                                if (image != null) {
                                  cont.setImageFile(image);
                                }
                              },
                            ),
                      ],
                    ),
                    gapH20,
                    DialogTextField(
                      textEditingController: cont.fullCompanyName,
                      text: 'full_company_name'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    PhoneTextField(
                      textEditingController: cont.mobile,
                      initialValue: cont.selectedMobileCode,
                      text: 'mobile'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                      validationFunc: (val) {
                        if (val.isNotEmpty && val.length < 9) {
                          return '7_digits'.tr;
                        }
                        return null;
                      },
                      onCodeSelected: (value) {
                        cont.setSelectedMobileCode(value);
                      },
                      onChangedFunc: (value) {
                        setState(() {
                          // mainDescriptionController.text=value;
                        });
                      },
                    ),
                    gapH6,
                    PhoneTextField(
                      textEditingController: cont.phone,
                      text: 'phone'.tr,
                      initialValue: cont.selectedPhoneCode,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                      validationFunc: (val) {
                        if (val.isNotEmpty && val.length < 9) {
                          return '7_digits'.tr;
                        }
                        return null;
                      },
                      onCodeSelected: (value) {
                        cont.setSelectedPhoneCode(value);
                      },
                      onChangedFunc: (value) {
                        setState(() {
                          // mainDescriptionController.text=value;
                        });
                      },
                    ),
                    gapH6,
                    DialogTextField(
                      textEditingController: cont.email,
                      text: 'email'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    DialogTextField(
                      textEditingController: cont.address,
                      text: 'address'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    DialogTextField(
                      textEditingController: cont.bankInformation,
                      text: 'bank_information'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    DialogTextField(
                      textEditingController: cont.localPayments,
                      text: 'local_payments'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    DialogTextField(
                      textEditingController: cont.trn,
                      text: 'trn'.tr,
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    DialogNumericTextField(
                      textEditingController: cont.vat,
                      text: '${'vat'.tr} %',
                      rowWidth: MediaQuery.of(context).size.width * 0.72,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (value) {
                        // if(value.isEmpty){
                        //   return 'required_field'.tr;
                        // }
                        // return null;
                      },
                    ),
                    gapH6,
                    Row(
                      children: [
                        Checkbox(
                          value: cont.isCompanySubjectToVat,
                          onChanged: (bool? value) {
                            cont.setIsCompanySubjectToVat(value!);
                          },
                        ),
                        gapW8,
                        Text('company_subject_to_vat'.tr),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        )
        : Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.65,
          child: GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return RawScrollbar(
                controller: scrollController,
                thumbVisibility: true,
                thickness: 8,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gapH32,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          cont.imageFile != null
                              ? InkWell(
                                onTap: () async {
                                  final image =
                                      await ImagePickerHelper.pickImage();
                                  cont.setImageFile(image!);
                                },
                                child: ReusablePhotoCircle(
                                  imageFilePassed: cont.imageFile!,
                                ),
                              )
                              : cont.logo.isNotEmpty
                              ? InkWell(
                                onTap: () async {
                                  final image =
                                      await ImagePickerHelper.pickImage();
                                  cont.setImageFile(image!);
                                },
                                child: ReusablePhotoCard(url: cont.logo),
                              )
                              : ReusableAddPhotoCircle(
                                onTapCircle: () async {
                                  final image =
                                      await ImagePickerHelper.pickImage();
                                  if (image != null) {
                                    cont.setImageFile(image);
                                  }
                                },
                              ),
                        ],
                      ),
                      gapH20,
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DialogTextField(
                                textEditingController: cont.fullCompanyName,
                                text: 'full_company_name'.tr,
                                rowWidth:
                                    MediaQuery.of(context).size.width * 0.35,
                                textFieldWidth:
                                    MediaQuery.of(context).size.width * 0.25,
                                validationFunc: (value) {
                                  // if(value.isEmpty){
                                  //   return 'required_field'.tr;
                                  // }
                                  // return null;
                                },
                              ),
                            ],
                          ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PhoneTextField(
                            textEditingController: cont.mobile,
                            initialValue: cont.selectedMobileCode,
                            text: 'mobile'.tr,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (val) {
                              if (val.isNotEmpty && val.length < 9) {
                                return '7_digits'.tr;
                              }
                              return null;
                            },
                            onCodeSelected: (value) {
                              cont.setSelectedMobileCode(value);
                            },
                            onChangedFunc: (value) {
                              setState(() {
                                // mainDescriptionController.text=value;
                              });
                            },
                          ),
                          PhoneTextField(
                            textEditingController: cont.phone,
                            text: 'phone'.tr,
                            initialValue: cont.selectedPhoneCode,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (val) {
                              if (val.isNotEmpty && val.length < 9) {
                                return '7_digits'.tr;
                              }
                              return null;
                            },
                            onCodeSelected: (value) {
                              cont.setSelectedPhoneCode(value);
                            },
                            onChangedFunc: (value) {
                              setState(() {
                                // mainDescriptionController.text=value;
                              });
                            },
                          ),
                        ],
                      ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController: cont.email,
                            text: 'email'.tr,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                          ),
                          DialogTextField(
                            textEditingController: cont.address,
                            text: 'address'.tr,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                          ),
                        ],
                      ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController: cont.bankInformation,
                            text: 'bank_information'.tr,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                          ),
                          DialogTextField(
                            textEditingController: cont.localPayments,
                            text: 'local_payments'.tr,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                          ),
                        ],
                      ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController: cont.trn,
                            text: 'trn'.tr,
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                          ),
                          DialogNumericTextField(
                            textEditingController: cont.vat,
                            text: '${'vat'.tr} %',
                            rowWidth: MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        children: [
                          Checkbox(
                            value: cont.isCompanySubjectToVat,
                            onChanged: (bool? value) {
                              cont.setIsCompanySubjectToVat(value!);
                            },
                          ),
                          gapW8,
                          Text('company_subject_to_vat'.tr),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }
}



class ReusableCASALAGOHeaderSection extends StatefulWidget {
  const ReusableCASALAGOHeaderSection({super.key, required this.index});
  final int index;
  @override
  State<ReusableCASALAGOHeaderSection> createState() => _ReusableCASALAGOHeaderSectionState();
}

class _ReusableCASALAGOHeaderSectionState extends State<ReusableCASALAGOHeaderSection> {
  HomeController homeController = Get.find();
  Uint8List? imageFile;
  String selectedPhoneCode = '', selectedMobileCode = '',logo='';
  TextEditingController headerName=TextEditingController();
  TextEditingController fullCompanyName=TextEditingController();
  TextEditingController address=TextEditingController();
  TextEditingController mobile=TextEditingController();
  TextEditingController phone=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController trn=TextEditingController();
  TextEditingController bankInformation=TextEditingController();
  TextEditingController localPayments=TextEditingController();
  TextEditingController vat=TextEditingController();
  bool isCompanySubjectToVat = true;
  @override
  void initState() {
    headerName.text='Header${widget.index+1}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(top: 5.0),
      padding:
           EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      decoration:BoxDecoration(

        border: Border.all(
          color: Primary.primary.withAlpha((0.2 * 255).toInt()),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
          width: MediaQuery.of(context).size.width * 0.8,
          child: GetBuilder<CompanySettingsController>(
            builder: (cont) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // gapH32,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      imageFile != null
                          ? InkWell(
                            onTap: () async {
                              final image =
                                  await ImagePickerHelper.pickImage();
                              cont.updateLogoFile(widget.index,image!);
                            },
                            child: ReusablePhotoCircle(
                              imageFilePassed:imageFile!,
                            ),
                          )
                          : logo.isNotEmpty
                          ? InkWell(
                            onTap: () async {
                              final image =
                                  await ImagePickerHelper.pickImage();
                              cont.updateLogoFile(widget.index,image!);
                            },
                            child: ReusablePhotoCard(url: logo),
                          )
                          : ReusableAddPhotoCircle(
                            onTapCircle: () async {
                              final image =
                                  await ImagePickerHelper.pickImage();
                              if (image != null) {
                                cont.updateLogoFile(widget.index,image);
                              }
                            },
                          ),
                    ],
                  ),
                  gapH20,
                  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController: headerName,
                            text: 'header'.tr,
                            rowWidth:
                                MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              if (value.isEmpty) {
                                return 'required_field'.tr;
                              }
                              return null;
                            },
                            onChangedFunc: (val){
                              cont.updateFullCompanyName(widget.index,val);
                            },
                          ),
                          DialogTextField(
                            textEditingController: fullCompanyName,
                            text: 'full_company_name'.tr,
                            rowWidth:
                                MediaQuery.of(context).size.width * 0.35,
                            textFieldWidth:
                                MediaQuery.of(context).size.width * 0.25,
                            validationFunc: (value) {
                              // if(value.isEmpty){
                              //   return 'required_field'.tr;
                              // }
                              // return null;
                            },
                            onChangedFunc: (val){
                              cont.updateFullCompanyName(widget.index,val);
                            },
                          ),
                        ],
                      ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PhoneTextField(
                        textEditingController: mobile,
                        initialValue: selectedMobileCode,
                        text: 'mobile'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (val) {
                          if (val.isNotEmpty && val.length < 9) {
                            return '7_digits'.tr;
                          }
                          return null;
                        },
                        onCodeSelected: (value) {
                          cont.updateMobileCode(widget.index,value);
                        },
                        onChangedFunc: (value) {
                          cont.updateMobileNumber(widget.index,value);
                        },
                      ),
                      PhoneTextField(
                        textEditingController: phone,
                        text: 'phone'.tr,
                        initialValue: selectedPhoneCode,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (val) {
                          if (val.isNotEmpty && val.length < 9) {
                            return '7_digits'.tr;
                          }
                          return null;
                        },
                        onCodeSelected: (value) {
                          cont.updatePhoneCode(widget.index,value);
                        },
                        onChangedFunc: (value) {
                          cont.updatePhoneNumber(widget.index,value);
                        },
                      ),
                    ],
                  ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DialogTextField(
                        textEditingController: email,
                        text: 'email'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (value) {
                          // if(value.isEmpty){
                          //   return 'required_field'.tr;
                          // }
                          // return null;
                        },
                        onChangedFunc: (val){
                          cont.updateCompanyEmail(widget.index,val);
                        },
                      ),
                      DialogTextField(
                        textEditingController: address,
                        text: 'address'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (value) {
                          // if(value.isEmpty){
                          //   return 'required_field'.tr;
                          // }
                          // return null;
                        },
                        onChangedFunc: (val){
                          cont.updateAddress(widget.index,val);
                        },
                      ),
                    ],
                  ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DialogTextField(
                        textEditingController: bankInformation,
                        text: 'bank_information'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (value) {
                          // if(value.isEmpty){
                          //   return 'required_field'.tr;
                          // }
                          // return null;
                        },
                        onChangedFunc: (val){
                          cont.updateBankInfo(widget.index,val);
                        },
                      ),
                      DialogTextField(
                        textEditingController: localPayments,
                        text: 'local_payments'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (value) {
                          // if(value.isEmpty){
                          //   return 'required_field'.tr;
                          // }
                          // return null;
                        },
                        onChangedFunc: (val){
                          cont.updateLocalPayments(widget.index,val);
                        },
                      ),
                    ],
                  ),
                  gapH6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DialogTextField(
                        textEditingController: trn,
                        text: 'trn'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (value) {
                          // if(value.isEmpty){
                          //   return 'required_field'.tr;
                          // }
                          // return null;
                        },
                        onChangedFunc: (val){
                          cont.updateTrn(widget.index,val);
                        },
                      ),
                      ReusableInputNumberField(
                        controller: vat,
                        text: '${'vat'.tr} %',
                        rowWidth: MediaQuery.of(context).size.width * 0.35,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.25,
                        validationFunc: (value) {
                          // if(value.isEmpty){
                          //   return 'required_field'.tr;
                          // }
                          // return null;
                        },
                        onChangedFunc: (val){
                          cont.updateVat(widget.index,val);
                        },
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    children: [
                      Checkbox(
                        value: isCompanySubjectToVat,
                        onChanged: (bool? value) {
                          cont.updateCompanySubjectToVat(widget.index,value==true?'1':'0');
                        },
                      ),
                      gapW8,
                      Text('company_subject_to_vat'.tr),
                    ],
                  ),
                ],
              );
            },
          ),
        );
  }
}
