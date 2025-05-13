import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/CurrenciesAndRates/add_new_currency.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/CurrenciesAndRates/delete_currency.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/CurrenciesAndRates/update_currency.dart';
import 'package:rooster_app/Backend/ConfigurationsBackend/send_exchange_rate.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../../const/functions.dart';




class CurrenciesAndRatesDialogContent extends StatefulWidget {
  const CurrenciesAndRatesDialogContent({super.key});
  @override
  State<CurrenciesAndRatesDialogContent> createState() =>
      _CurrenciesAndRatesDialogContentState();
}

class _CurrenciesAndRatesDialogContentState
    extends State<CurrenciesAndRatesDialogContent> {
  int selectedTabIndex = 0;
  ExchangeRatesController exchangeRatesController=Get.find();
  List tabsList = [
    'currencies',
    'rates'
  ];

  List tabsContent = [
    const CurrenciesTabInCurrenciesAndRates(),
    const RatesTabInCurrenciesAndRates(),
  ];
  final HomeController homeController = Get.find();
  @override
  void initState() {
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack(withUsd: false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height:homeController.isMobile.value ?MediaQuery.of(context).size.height * 0.75: MediaQuery.of(context).size.height * 0.9,
      margin:homeController.isMobile.value? const EdgeInsets.symmetric(horizontal: 10, vertical: 15):const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTitle(text: 'currencies_and_rates'.tr),
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
          tabsContent[selectedTabIndex],
        ],
      ),
    );
  }
  Widget _buildTabChipItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        if(index==1 && exchangeRatesController.currenciesIdsList.isEmpty){
          CommonWidgets.snackBar('error', 'There are no Currencies other than USD');
        }else{
        setState(() {
          selectedTabIndex = index;
        });}
      },
      child: ClipPath(
        clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9)))),
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.09,
          // height: MediaQuery.of(context).size.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
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
  }


  // Widget _ratesTabInCurrencies() {
  //   return GetBuilder<ExchangeRatesController>(
  //     builder: (cont) {
  //       return SizedBox(
  //         height: MediaQuery.of(context).size.height * 0.65,
  //         child: Column(
  //           // crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Column(
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
  //                   decoration: BoxDecoration(
  //                       color: Primary.primary,
  //                       borderRadius: const BorderRadius.all(Radius.circular(6))),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       TableTitle(
  //                         text: 'currency'.tr,
  //                         width: MediaQuery.of(context).size.width * 0.22,
  //                       ),
  //                       TableTitle(
  //                         text: 'exchange_rate'.tr,
  //                         width: MediaQuery.of(context).size.width * 0.32,
  //                       ),
  //                       TableTitle(
  //                         text: 'start_date'.tr,
  //                         width: MediaQuery.of(context).size.width * 0.22,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 isClicked
  //                     ? Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
  //                   // height: 55,
  //                   decoration: BoxDecoration(
  //                       color:
  //                       Primary.p10 ,
  //                       borderRadius: const BorderRadius.all(Radius.circular(0))),
  //                   child: Form(
  //                     key: _formKey,
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         DropdownMenu<String>(
  //                           width: MediaQuery.of(context).size.width * 0.2,
  //                           // requestFocusOnTap: false,
  //                           enableSearch: true,
  //                           controller: currencyController,
  //                           hintText: '',
  //                           inputDecorationTheme: InputDecorationTheme(
  //                             // filled: true,
  //                             hintStyle: const TextStyle(fontStyle: FontStyle.italic),
  //                             contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
  //                             // outlineBorder: BorderSide(color: Colors.black,),
  //                             enabledBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(
  //                                   color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
  //                               borderRadius:
  //                               const BorderRadius.all(Radius.circular(9)),
  //                             ),
  //                             focusedBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(
  //                                   color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
  //                               borderRadius:
  //                               const BorderRadius.all(Radius.circular(9)),
  //                             ),
  //                           ),
  //                           // menuStyle: ,
  //                           menuHeight: 250,
  //                           dropdownMenuEntries: cont.currenciesNamesList
  //                               .map<DropdownMenuEntry<String>>((String option) {
  //                             return DropdownMenuEntry<String>(
  //                               value: option,
  //                               label: option,
  //                             );
  //                           }).toList(),
  //                           enableFilter: true,
  //                           onSelected: (String? val) {
  //                             setState(() {
  //                               selectedItem = val!;
  //                               var index = cont.currenciesNamesList.indexOf(val);
  //                               selectedCurrencyId = cont.currenciesIdsList[index];
  //                             });
  //                           },
  //                         ),
  //                         DialogNumericTextField(
  //                           textEditingController: exchangeRateController,
  //                           text: '',
  //                           rowWidth: MediaQuery.of(context).size.width * 0.3,
  //                           textFieldWidth: MediaQuery.of(context).size.width * 0.3,
  //                           validationFunc: (val) {},
  //                         ),
  //                         SizedBox(
  //                           width: MediaQuery.of(context).size.width * 0.2,
  //                           child:  DialogDateTextField(
  //                             onChangedFunc: (value) {},
  //                             onDateSelected: (value) {
  //                               startDate=value;
  //                             },
  //                             textEditingController: startDateController,
  //                             text: '',
  //                             textFieldWidth: MediaQuery.of(context).size.width * 0.2,
  //                             validationFunc: (val) {},
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 )
  //                     : const SizedBox(),
  //                 cont.isExchangeRatesFetched?Container(
  //                   color: Colors.white,
  //                   height: cont.exchangeRatesList.length * 50,
  //                   child: ListView.builder(
  //                     itemCount: cont.exchangeRatesList.length, //products is data from back res
  //                     itemBuilder: (context, index) => ExchangeRateAsRowInTable(
  //                       index: index,
  //                     ),
  //                   ),
  //                 ):const Center(child: CircularProgressIndicator(),),
  //                 gapH10,
  //                 isClicked
  //                     ?const SizedBox()
  //                     :   ReusableAddCard(
  //                   text: 'new_exchange_rate'.tr,
  //                   onTap: () {
  //                     setState(() {
  //                       isClicked = true;
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //             isClicked
  //                 ?const SizedBox()
  //                 : Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 TextButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         exchangeRateController.clear();
  //                         startDateController.clear();
  //                         currencyController.clear();
  //                       });
  //                     },
  //                     child: Text(
  //                       'discard'.tr,
  //                       style: TextStyle(
  //                           decoration: TextDecoration.underline,
  //                           color: Primary.primary),
  //                     )),
  //                 gapW24,
  //                 ReusableButtonWithColor(
  //                     btnText: 'save'.tr,
  //                     onTapFunction: () async {
  //                       if(_formKey.currentState!.validate()) {
  //                         var p = await sendExchangeRate(selectedCurrencyId,
  //                             exchangeRateController.text, startDate);
  //                         if (p['success'] == true) {
  //                           Get.back();
  //                           CommonWidgets.snackBar('', p['message']);
  //                           exchangeRateController.clear();
  //                           startDateController.clear();
  //                           currencyController.clear();
  //                         } else {
  //                           CommonWidgets.snackBar(
  //                               'error', p['message']);
  //                         }
  //                       }
  //                     },
  //                     width: 100,
  //                     height: 35),
  //               ],
  //             )
  //           ],
  //         ),
  //       );
  //     }
  //   );
  // }
  // Widget _generalTabInCurrencies() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.3,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text('${'currency'.tr}*'),
  //                 DropdownMenu<String>(
  //                   width: MediaQuery.of(context).size.width * 0.15,
  //                   // requestFocusOnTap: false,
  //                   enableSearch: true,
  //                   controller: currencyController,
  //                   hintText: '',
  //                   inputDecorationTheme: InputDecorationTheme(
  //                     // filled: true,
  //                     hintStyle: const TextStyle(fontStyle: FontStyle.italic),
  //                     contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
  //                     // outlineBorder: BorderSide(color: Colors.black,),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderSide: BorderSide(
  //                           color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
  //                       borderRadius:
  //                           const BorderRadius.all(Radius.circular(9)),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderSide: BorderSide(
  //                           color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
  //                       borderRadius:
  //                           const BorderRadius.all(Radius.circular(9)),
  //                     ),
  //                   ),
  //                   // menuStyle: ,
  //                   menuHeight: 250,
  //                   dropdownMenuEntries: currenciesNamesList
  //                       .map<DropdownMenuEntry<String>>((String option) {
  //                     return DropdownMenuEntry<String>(
  //                       value: option,
  //                       label: option,
  //                     );
  //                   }).toList(),
  //                   enableFilter: true,
  //                   onSelected: (String? val) {
  //                     setState(() {
  //                       selectedItem = val!;
  //                       var index = currenciesNamesList.indexOf(val);
  //                       selectedCurrencyId = currenciesIdsList[index];
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           gapH16,
  //           DialogNumericTextField(
  //             textEditingController: exchangeRateController,
  //             text: '${'exchange_rate'.tr}*',
  //             rowWidth: MediaQuery.of(context).size.width * 0.3,
  //             textFieldWidth: MediaQuery.of(context).size.width * 0.15,
  //             validationFunc: () {},
  //           ),
  //           gapH16,
  //           SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.3,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   '${'start_date'.tr}*',
  //                 ),
  //                 DialogDateTextField(
  //                   onChangedFunc: (value) {},
  //                   onDateSelected: (value) {
  //                     startDate=value;
  //                   },
  //                   textEditingController: startDateController,
  //                   text: '',
  //                   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
  //                   validationFunc: () {},
  //                 ),
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ],
  //   );
  // }
}

class ExchangeRateAsRowInTable extends StatefulWidget {
  const ExchangeRateAsRowInTable({super.key, required this.index});
  final int index;

  @override
  State<ExchangeRateAsRowInTable> createState() => _ExchangeRateAsRowInTableState();
}

class _ExchangeRateAsRowInTableState extends State<ExchangeRateAsRowInTable> {
  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<ExchangeRatesController>(
        builder: (cont) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,  vertical: 15),
            decoration: BoxDecoration(
                color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TableItem(
                  text: '${cont.exchangeRatesList[widget.index]['currency'] ?? ''}',
                  width:homeController.isMobile.value? 150:MediaQuery.of(context).size.width * 0.22,
                ),
                TableItem(
                  text: cont.exchangeRatesList[widget.index]['exchange_rate']!=null?numberWithComma('${cont.exchangeRatesList[widget.index]['exchange_rate']}'): '',
                  width:homeController.isMobile.value? 150: MediaQuery.of(context).size.width * 0.32,
                ),
                TableItem(
                  text: '${cont.exchangeRatesList[widget.index]['start_date'] ?? ''}',
                  width:homeController.isMobile.value? 200: MediaQuery.of(context).size.width * 0.22,
                ),
              ],
            ),
          );
        }
    );
  }
}


class CurrenciesTabInCurrenciesAndRates extends StatefulWidget {
  const CurrenciesTabInCurrenciesAndRates({super.key});

  @override
  State<CurrenciesTabInCurrenciesAndRates> createState() => _CurrenciesTabInCurrenciesAndRatesState();
}

class _CurrenciesTabInCurrenciesAndRatesState extends State<CurrenciesTabInCurrenciesAndRates> {
  bool isClicked = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  ExchangeRatesController exchangeRatesController=Get.find();
  HomeController homeController=Get.find();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExchangeRatesController>(
        builder: (cont) {
          return SizedBox(
            height:homeController.isMobile.value ?MediaQuery.of(context).size.height* 0.6: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?10: 40, vertical: 15),
                      decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius: const BorderRadius.all(Radius.circular(6))),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TableTitle(
                            text: 'name'.tr,
                            width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                          ),
                          // gapW16,
                          TableTitle(
                            text: 'symbol'.tr,
                            width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,)
                        ],
                      ),
                    ),
                    isClicked
                        ? Container(
                      padding:  EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?10: 40,vertical: 15),
                      // height: 55,
                      decoration: BoxDecoration(
                          color:
                          Primary.p10 ,
                          borderRadius: const BorderRadius.all(Radius.circular(0))),
                      child: Form(
                        key: _formKey,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogTextField(
                              textEditingController: nameController,
                              text: '',
                              rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                              textFieldWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.2,
                              validationFunc: (String val) {
                                if(val.isEmpty){
                                  return 'required_field'.tr;
                                }return null;
                              },
                            ),
                            // gapW16,
                            DialogTextField(
                              textEditingController: symbolController,
                              text: '',
                              rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                              textFieldWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.2,
                              validationFunc:(String val) {
                                if(val.isEmpty){
                                  return 'required_field'.tr;
                                }return null;
                              },
                            ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,)
                          ],
                        ),
                      ),
                    )
                        : const SizedBox(),
                    cont.isExchangeRatesFetched?Container(
                      color: Colors.white,
                      height: cont.currenciesList.length>6? MediaQuery.of(context).size.height * 0.4:cont.currenciesList.length* 55,
                      child: ListView.builder(
                        itemCount: cont.currenciesList.length,
                        itemBuilder: (context, index) => CurrencyAsRowInTable(
                          index: index,
                        ),
                      ),
                    ):const Center(child: CircularProgressIndicator(),),
                    gapH10,
                    isClicked
                        ?const SizedBox()
                        :   ReusableAddCard(
                      text: 'new_currency'.tr,
                      onTap: () {
                        setState(() {
                          isClicked = true;
                        });
                      },
                    ),
                  ],
                ),
                isClicked==false
                    ?const SizedBox()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            nameController.clear();
                            symbolController.clear();
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
                          if(_formKey.currentState!.validate()) {
                            var p = await addCurrency(nameController.text, symbolController.text);
                            if (p['success'] == true) {
                              // Get.back();
                              CommonWidgets.snackBar('', p['message']);
                              cont.getExchangeRatesListAndCurrenciesFromBack(withUsd: false);
                              nameController.clear();
                              symbolController.clear();
                            } else {
                              CommonWidgets.snackBar(
                                  'error', p['message']);
                            }
                          }
                        },
                        width: 100,
                        height: 35),
                  ],
                )
              ],
            ),
          );
        }
    );
  }
}

class RatesTabInCurrenciesAndRates extends StatefulWidget {
  const RatesTabInCurrenciesAndRates({super.key});

  @override
  State<RatesTabInCurrenciesAndRates> createState() => _RatesTabInCurrenciesAndRatesState();
}

class _RatesTabInCurrenciesAndRatesState extends State<RatesTabInCurrenciesAndRates> {
  bool isClicked = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController currencyController = TextEditingController();
  TextEditingController exchangeRateController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  String selectedCurrencyId = '';
  // String? selectedItem = '';
  String startDate = '';
  ExchangeRatesController exchangeRatesController=Get.find();
  HomeController homeController=Get.find();
  @override
  void initState() {
    startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    selectedCurrencyId = '${exchangeRatesController.currenciesIdsList[0]??'0'}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExchangeRatesController>(
        builder: (cont) {
          return cont.isExchangeRatesFetched?SizedBox(
            height:homeController.isMobile.value ?MediaQuery.of(context).size.height* 0.6: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                homeController.isMobile.value ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child:cont.isExchangeRatesFetched
                      ?  SingleChildScrollView(
                    child: Row(
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child:Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    decoration: BoxDecoration(
                                        color: Primary.primary,
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Row(
                                      children: [
                                        TableTitle(
                                          text: 'currency'.tr,
                                          width: 150,
                                        ),
                                        TableTitle(
                                          text: 'exchange_rate'.tr,
                                          width:150,
                                        ),
                                        TableTitle(
                                          text: 'start_date'.tr,
                                          width:200,
                                        ),
                                      ],
                                    ),
                                  ),
                                  isClicked
                                      ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                                    // height: 55,
                                    decoration: BoxDecoration(
                                        color:
                                        Primary.p10 ,
                                        borderRadius: const BorderRadius.all(Radius.circular(0))),
                                    child: Form(
                                      key: _formKey,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          DropdownMenu<String>(
                                            width: 150,
                                            requestFocusOnTap: false,
                                            controller: currencyController,
                                            hintText: cont.currenciesNamesList[cont.currenciesIdsList.indexOf(selectedCurrencyId)],
                                            inputDecorationTheme: InputDecorationTheme(
                                              // filled: true,
                                              contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                                              // outlineBorder: BorderSide(color: Colors.black,),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                                                borderRadius: const BorderRadius.all(Radius.circular(9)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                                                borderRadius: const BorderRadius.all(Radius.circular(9)),
                                              ),
                                            ),
                                            // menuStyle: ,
                                            dropdownMenuEntries:
                                            cont.currenciesNamesList.map<DropdownMenuEntry<String>>((String option) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            }).toList(),
                                            onSelected: (String? val) {
                                              var index = cont.currenciesNamesList.indexOf(val!);
                                              setState(() {
                                                selectedCurrencyId=cont.currenciesIdsList[index];
                                              });
                                            },
                                          ),
                                          DialogNumericTextField(
                                            textEditingController: exchangeRateController,
                                            text: '',
                                            rowWidth: 150,
                                            textFieldWidth: 140,
                                            validationFunc:(String val) {
                                              if(val.isEmpty){
                                                return 'required_field'.tr;
                                              }return null;
                                            },
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            width: 200,
                                            child:  DialogDateTextField(
                                              onChangedFunc: (value) {},
                                              onDateSelected: (value) {
                                                setState(() {
                                                  startDate=value;
                                                });
                                                startDateController.text=value;
                                              },
                                              textEditingController: startDateController,
                                              text: '',
                                              textFieldWidth: 190,
                                              validationFunc: (String val) {
                                                if(val.isEmpty){
                                                  return 'required_field'.tr;
                                                }return null;
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                      : const SizedBox(),
                                  Container(
                                      color: Colors.white,
                                      child:Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children:  List.generate(
                                            cont.exchangeRatesList.length,
                                              (index) =>  ExchangeRateAsRowInTable(
                                                index: index,
                                              ),
                                        ),
                                      )
                                  ),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                  ):const Center(child:CircularProgressIndicator()),
                ):
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius: const BorderRadius.all(Radius.circular(6))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TableTitle(
                            text: 'currency'.tr,
                            width: MediaQuery.of(context).size.width * 0.22,
                          ),
                          TableTitle(
                            text: 'exchange_rate'.tr,
                            width: MediaQuery.of(context).size.width * 0.32,
                          ),
                          TableTitle(
                            text: 'start_date'.tr,
                            width: MediaQuery.of(context).size.width * 0.22,
                          ),
                        ],
                      ),
                    ),
                    isClicked
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                      // height: 55,
                      decoration: BoxDecoration(
                          color:
                          Primary.p10 ,
                          borderRadius: const BorderRadius.all(Radius.circular(0))),
                      child: Form(
                        key: _formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // DropdownMenu<String>(
                            //   width: MediaQuery.of(context).size.width * 0.2,
                            //   // enableSearch: true,
                            //   requestFocusOnTap: false,
                            //   controller: currencyController,
                            //   hintText:  cont.currenciesNamesList[cont.currenciesIdsList.indexOf(selectedCurrencyId)],
                            //   inputDecorationTheme: InputDecorationTheme(
                            //     // filled: true,
                            //     hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                            //     contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                            //     // outlineBorder: BorderSide(color: Colors.black,),
                            //     enabledBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //           color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                            //       borderRadius:
                            //       const BorderRadius.all(Radius.circular(9)),
                            //     ),
                            //     focusedBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(
                            //           color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                            //       borderRadius:
                            //       const BorderRadius.all(Radius.circular(9)),
                            //     ),
                            //   ),
                            //   // menuStyle: ,
                            //   menuHeight: 250,
                            //   dropdownMenuEntries: cont.currenciesNamesList
                            //       .map<DropdownMenuEntry<String>>((String option) {
                            //     return DropdownMenuEntry<String>(
                            //       value: option,
                            //       label: option,
                            //     );
                            //   }).toList(),
                            //   enableFilter: true,
                            //   onSelected: (String? val) {
                            //     setState(() {
                            //       // selectedItem = val!;
                            //       var index = cont.currenciesNamesList.indexOf(val!);
                            //       selectedCurrencyId = cont.currenciesIdsList[index];
                            //     });
                            //   },
                            // ),
                            DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.2,
                              requestFocusOnTap: false,
                              controller: currencyController,
                              hintText: cont.currenciesNamesList[cont.currenciesIdsList.indexOf(selectedCurrencyId)],
                              inputDecorationTheme: InputDecorationTheme(
                                // filled: true,
                                contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                                // outlineBorder: BorderSide(color: Colors.black,),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                                ),
                              ),
                              // menuStyle: ,
                              dropdownMenuEntries:
                              cont.currenciesNamesList.map<DropdownMenuEntry<String>>((String option) {
                                return DropdownMenuEntry<String>(
                                  value: option,
                                  label: option,
                                );
                              }).toList(),
                              onSelected: (String? val) {
                                var index = cont.currenciesNamesList.indexOf(val!);
                                setState(() {
                                  selectedCurrencyId=cont.currenciesIdsList[index];
                                });
                              },
                            ),
                            DialogNumericTextField(
                              textEditingController: exchangeRateController,
                              text: '',
                              rowWidth: MediaQuery.of(context).size.width * 0.3,
                              textFieldWidth: MediaQuery.of(context).size.width * 0.3,
                              validationFunc:(String val) {
                                if(val.isEmpty){
                                  return 'required_field'.tr;
                                }return null;
                              },
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child:  DialogDateTextField(
                                onChangedFunc: (value) {},
                                onDateSelected: (value) {
                                  setState(() {
                                    startDate=value;
                                  });
                                  startDateController.text=value;
                                },
                                textEditingController: startDateController,
                                text: '',
                                textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                                validationFunc: (String val) {
                                  if(val.isEmpty){
                                    return 'required_field'.tr;
                                  }return null;
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                        : const SizedBox(),
                    cont.isExchangeRatesFetched?Container(
                      color: Colors.white,
                      height: cont.exchangeRatesList.length<6?cont.exchangeRatesList.length * 55:MediaQuery.of(context).size.height * 0.4,
                      child: ListView.builder(
                        itemCount: cont.exchangeRatesList.length, //products is data from back res
                        itemBuilder: (context, index) => ExchangeRateAsRowInTable(
                          index: index,
                        ),
                      ),
                    ):const Center(child: CircularProgressIndicator(),),
                    gapH10,
                    isClicked
                        ?const SizedBox()
                        :   ReusableAddCard(
                      text: 'new_exchange_rate'.tr,
                      onTap: () {
                        setState(() {
                          isClicked = true;
                        });
                      },
                    ),
                  ],
                ),
                isClicked==false
                    ?const SizedBox()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            exchangeRateController.clear();
                            startDateController.clear();
                            currencyController.clear();
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
                          if(_formKey.currentState!.validate()) {
                            var p = await sendExchangeRate(selectedCurrencyId,
                                exchangeRateController.text, startDate);
                            if (p['success'] == true) {
                              // Get.back();
                              CommonWidgets.snackBar('', p['message']);
                              cont.getExchangeRatesListAndCurrenciesFromBack(withUsd: false);
                              exchangeRateController.clear();
                              startDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              selectedCurrencyId = '${exchangeRatesController.currenciesIdsList[0]??'0'}';
                            } else {
                              CommonWidgets.snackBar(
                                  'error', p['message']);
                            }
                          }
                        },
                        width: 100,
                        height: 35),
                  ],
                )
              ],
            ),
          ):loading();
        }
    );
  }
}


class CurrencyAsRowInTable extends StatefulWidget {
  const CurrencyAsRowInTable({super.key, required this.index});
  final int index;

  @override
  State<CurrencyAsRowInTable> createState() => _CurrencyAsRowInTableState();
}

class _CurrencyAsRowInTableState extends State<CurrencyAsRowInTable> {
  HomeController homeController=Get.find();
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<ExchangeRatesController>(
        builder: (cont) {
          return InkWell(
            onDoubleTap: (){
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) =>
                      AlertDialog(
                          backgroundColor:
                          Colors.white,
                          shape:
                          const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    9)),
                          ),
                          elevation: 0,
                          content: UpdateCurrencyDialog(index:widget.index,)));
            },
            child: Container(
              padding:   EdgeInsets.symmetric(horizontal: homeController.isMobile.value ?10:40,  vertical: 15),
              decoration: BoxDecoration(
                  color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(0))),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TableItem(
                    text: '${cont.currenciesList[widget.index]['name'] ?? ''}',
                    width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                  ),
                  // gapW16,
                  TableItem(
                    text: '${cont.currenciesList[widget.index]['symbol'] ?? ''}',
                    width: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3:MediaQuery.of(context).size.width * 0.2,
                  ),
                  // gapW16,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                    child: InkWell(
                      onTap: () async{
                        var res = await deleteCurrency(
                            '${cont.currenciesList[widget.index]['id']}');
                        var p = json.decode(res.body);
                        if (res.statusCode == 200) {
                          CommonWidgets.snackBar('Success',
                              p['message']);
                          // warehouseController.resetValues();
                          cont.getExchangeRatesListAndCurrenciesFromBack(withUsd: false);
                        } else {
                          CommonWidgets.snackBar(
                              'error',  p['message']);
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
        }
    );
  }
}

class UpdateCurrencyDialog extends StatefulWidget {
  const UpdateCurrencyDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdateCurrencyDialog> createState() =>
      _UpdateCurrencyDialogState();
}

class _UpdateCurrencyDialogState extends State<UpdateCurrencyDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  ExchangeRatesController exchangeRatesController = Get.find();
  HomeController homeController = Get.find();
  @override
  void initState() {
    nameController.text='${exchangeRatesController.currenciesList[widget.index]['name'] ?? ''}';
    symbolController.text='${exchangeRatesController.currenciesList[widget.index]['symbol'] ?? ''}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
        color: Colors.white,
        height:homeController.isMobile.value ?300: 500,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              gapH20,
              DialogTextField(
                textEditingController: nameController,
                text: '${'name'.tr}*',
                rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.65: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.4: MediaQuery.of(context).size.width * 0.25,
                validationFunc: (String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }return null;
                },
              ),
              gapH16,
              DialogTextField(
                textEditingController: symbolController,
                text: '${'symbol'.tr}*',
                rowWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.65: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.4: MediaQuery.of(context).size.width * 0.25,
                validationFunc:(String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }return null;
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        nameController.text='${exchangeRatesController.currenciesList[widget.index]['name'] ?? ''}';
                        symbolController.text='${exchangeRatesController.currenciesList[widget.index]['symbol'] ?? ''}';
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
                          var p = await updateCurrency(
                            '${exchangeRatesController.currenciesList[widget.index]['id']}',
                            nameController.text,
                            symbolController.text,
                          );
                          if (p['success'] == true) {
                            Get.back();
                            exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack(withUsd: false);
                            nameController.clear();
                            symbolController.clear();
                            CommonWidgets.snackBar('success'.tr, p['message']);
                          } else {
                            CommonWidgets.snackBar('error', p['message']);
                          }
                        }
                      },
                      width: 100,
                      height: 35),
                ],
              ),
            ],
          ),
        )
    );
  }
}
