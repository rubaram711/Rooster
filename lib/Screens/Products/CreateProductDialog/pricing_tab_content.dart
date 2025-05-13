import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/products_controller.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

TextEditingController unitPriceController = TextEditingController();
TextEditingController decimalPriceController = TextEditingController();
TextEditingController discLineLimitController = TextEditingController();
TextEditingController priceCurrencyController = TextEditingController();
TextEditingController startDateForUpdateController = TextEditingController();
TextEditingController startTimeForUpdateController = TextEditingController();

class PricingTabContent extends StatefulWidget {
  const PricingTabContent({super.key});

  @override
  State<PricingTabContent> createState() => _PricingTabContentState();
}

class _PricingTabContentState extends State<PricingTabContent> {
  final _formKey = GlobalKey<FormState>();
  String startDate = '';
  String startTime = '';
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<ProductController>(
        builder: (cont) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gapH28,
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableInputNumberField(
                      controller: unitPriceController,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                      rowWidth:  MediaQuery.of(context).size.width * 0.22,
                      onChangedFunc: (){},
                      validationFunc: (value) {
                      // if(value.isEmpty){
                      //   return 'required_field'.tr;
                      // }return null;
                    }
                      ,text:'unit_price'.tr,),
                    gapW16,
                    cont.isProductsInfoFetched
                        ?DropdownMenu<String>(
                            width: MediaQuery.of(context).size.width * 0.07,
                            requestFocusOnTap: false,
                            controller: priceCurrencyController,
                            hintText: cont.currenciesNames[cont.currenciesIds.indexOf(cont.selectedPriceCurrencyId)],
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
                            cont.currenciesNames.map<DropdownMenuEntry<String>>((String option) {
                              return DropdownMenuEntry<String>(
                                value: option,
                                label: option,
                              );
                            }).toList(),
                            onSelected: (String? val) {
                              var index = cont.currenciesNames.indexOf(val!);
                              cont.setSelectedPriceCurrencyId(cont.currenciesIds[index]);
                            },
                          ):const Center(child: CircularProgressIndicator(),),
                    // gapW24,
                    // ReusableInputNumberField(
                    //   controller: decimalPriceController,
                    //   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                    //   rowWidth:  MediaQuery.of(context).size.width * 0.25,
                    //   onChangedFunc: (val){},validationFunc: (val){}
                    //   ,text: 'decimal_price'.tr,),
                    // SizedBox(width:MediaQuery.of(context).size.width * 0.15)
                  ],
                ),
                gapH24,
                // DialogTextField(
                //   validationFunc: (val){},
                //   textEditingController: discLineLimitController,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                //   rowWidth:  MediaQuery.of(context).size.width * 0.25
                //   ,text: 'disc_line_limit'.tr,),
                cont.isItUpdateProduct?Column(
                  children: [
                    gapH24,
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'start_date'.tr}*',
                          ),
                          DialogDateTextField(
                            onChangedFunc: (value) {},
                            onDateSelected: (value) {
                              startDate=value;
                              startDateForUpdateController.text=value;
                            },
                            textEditingController: startDateForUpdateController,
                            text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            textFieldWidth:  MediaQuery.of(context).size.width * 0.15,
                            validationFunc: () {},
                          ),
                        ],
                      ),
                    ),
                    gapH24,
                    SizedBox(
                      width:  MediaQuery.of(context).size.width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'start_time'.tr}*',
                          ),
                          DialogTimeTextField(
                            onChangedFunc: (value) {},
                            onTimeSelected: (value) {
                              startTime=value;
                            },
                            textEditingController: startTimeForUpdateController,
                            text:DateFormat.Hm().format(DateTime.now()),
                            textFieldWidth:  MediaQuery.of(context).size.width * 0.15,
                            validationFunc: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ):const SizedBox(),
                // const Spacer(),
                // ReusableBTNsRow(
                //   onBackClicked: (){
                //     cont.setSelectedTabIndex(3);
                //   },
                //   onDiscardClicked: (){
                //     cont.discardPricing();
                //   },
                //   onNextClicked: (){
                //     if(_formKey.currentState!.validate()){
                //       cont.setSelectedTabIndex(5);
                //     }
                //   },
                //   onSaveClicked: (){},
                // )
              ],
            ),
          ),
        );
      }
    );
  }
}





class MobilePricingTabContent extends StatefulWidget {
  const MobilePricingTabContent({super.key});

  @override
  State<MobilePricingTabContent> createState() => _MobilePricingTabContentState();
}

class _MobilePricingTabContentState extends State<MobilePricingTabContent> {
  final _formKey = GlobalKey<FormState>();
  String startDate = '';
  String startTime = '';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
        builder: (cont) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ReusableInputNumberField(
                      controller: unitPriceController,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.3,
                      rowWidth:  MediaQuery.of(context).size.width * 0.5,
                      onChangedFunc: (){},
                      validationFunc: (value) {
                      // if(value.isEmpty){
                      //   return 'required_field'.tr;
                      // }return null;
                    }
                      ,text: 'unit_price'.tr,),
                    gapW6,
                    cont.isProductsInfoFetched
                        ?DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width * 0.25,
                      requestFocusOnTap: false,
                      controller: priceCurrencyController,
                      hintText: cont.currenciesNames[cont.currenciesIds.indexOf(cont.selectedPriceCurrencyId)],
                      inputDecorationTheme: InputDecorationTheme(
                        // filled: true,
                        contentPadding: const EdgeInsets.fromLTRB(5, 0, 25, 5),
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
                      cont.currenciesNames.map<DropdownMenuEntry<String>>((String option) {
                        return DropdownMenuEntry<String>(
                          value: option,
                          label: option,
                        );
                      }).toList(),
                      onSelected: (String? val) {
                        var index = cont.currenciesNames.indexOf(val!);
                        cont.setSelectedPriceCurrencyId(cont.currenciesIds[index]);
                      },
                    ):const Center(child: CircularProgressIndicator(),),
                  ],
                ),
                // gapH24,
                // ReusableInputNumberField(
                //   controller: decimalPriceController,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                //   rowWidth:  MediaQuery.of(context).size.width * 0.8,
                //   onChangedFunc: (val){},validationFunc: (val){}
                //   ,text: 'decimal_price'.tr,),
                // gapH24,
                // DialogTextField(
                //   validationFunc: (val){},
                //   textEditingController: discLineLimitController,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                //   rowWidth:  MediaQuery.of(context).size.width * 0.8
                //   ,text: 'disc_line_limit'.tr,),
                cont.isItUpdateProduct?Column(
                  children: [
                    gapH24,
                    SizedBox(
                      width:  MediaQuery.of(context).size.width * 0.8  ,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'start_date'.tr}*',
                          ),
                          DialogDateTextField(
                            onChangedFunc: (value) {},
                            onDateSelected: (value) {
                              startDate=value;
                              startDateForUpdateController.text=value;
                            },
                            textEditingController: startDateForUpdateController,
                            text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            textFieldWidth:   MediaQuery.of(context).size.width * 0.4 ,
                            validationFunc: () {},
                          ),
                        ],
                      ),
                    ),
                    gapH24,
                    SizedBox(
                      width:   MediaQuery.of(context).size.width * 0.8   ,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'start_time'.tr}*',
                          ),
                          DialogTimeTextField(
                            onChangedFunc: (value) {},
                            onTimeSelected: (value) {
                              startTime=value;
                            },
                            textEditingController: startTimeForUpdateController,
                            text: DateFormat.Hm().format(DateTime.now()),
                            textFieldWidth:  MediaQuery.of(context).size.width * 0.4 ,
                            validationFunc: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ):const SizedBox(),
                // const Spacer(),
                // ReusableBTNsRow(
                //   onBackClicked: (){
                //     cont.setSelectedTabIndex(3);
                //   },
                //   onDiscardClicked: (){
                //     cont.discardPricing();
                //   },
                //   onNextClicked: (){
                //     if(_formKey.currentState!.validate()){
                //       cont.setSelectedTabIndex(5);
                //     }
                //   },
                //   onSaveClicked: (){},
                // )
              ],
            ),
          ),
        );
      }
    );
  }
}
