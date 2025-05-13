import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Widgets/loading.dart';
import '../../../Controllers/products_controller.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

TextEditingController unitCostController = TextEditingController();
TextEditingController decimalCostController = TextEditingController();
TextEditingController costCurrencyController = TextEditingController();
class ProcurementTabContent extends StatefulWidget {
  const ProcurementTabContent({super.key});

  @override
  State<ProcurementTabContent> createState() => _ProcurementTabContentState();
}

class _ProcurementTabContentState extends State<ProcurementTabContent> {
  // String selectedItem = "USD";
  // TextEditingController _unitCostController = TextEditingController();
  // TextEditingController _decimalCostController = TextEditingController();
  // @override
  // void initState() {
  //   _unitCostController.text = "0";
  //   _decimalCostController.text = "0";
  //   super.initState();
  // }
  ProductController productController = Get.find();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return  SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              gapH28,
              Form(
                key:_formKey,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ReusableInputNumberField(
                      controller:unitCostController ,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                      rowWidth:  MediaQuery.of(context).size.width * 0.22,
                      onChangedFunc: (){},
                      validationFunc: (value) {
                      // if(value.isEmpty){
                      //   return 'required_field'.tr;
                      // }return null;
                    }
                      ,text: 'unit_cost'.tr,),
gapW16,
                          cont.isProductsInfoFetched
                              ?DropdownMenu<String>(
                          width: MediaQuery.of(context).size.width * 0.07,
                          requestFocusOnTap: false,
                          controller: costCurrencyController,
                          hintText: cont.currenciesNames[cont.currenciesIds.indexOf(cont.selectedCurrencyId)],
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
                            cont.setSelectedCurrencyId(cont.currenciesIds[index]);
                          },
                        ):loading(),
                    // gapW24,
                    // ReusableInputNumberField(
                    //   controller: decimalCostController,
                    //   textFieldWidth: MediaQuery.of(context).size.width * 0.065,
                    //   rowWidth:  MediaQuery.of(context).size.width * 0.15,
                    //   onChangedFunc: (val){},validationFunc: (val){}
                    //   ,text: 'decimal_cost'.tr,),
                    // SizedBox(width:MediaQuery.of(context).size.width * 0.25)
                  ],
                ),
              ),
              // const Spacer(),
              // ReusableBTNsRow(
              //   onBackClicked: (){
              //     cont.setSelectedTabIndex(2);
              //   },
              //   onDiscardClicked: (){
              //     cont.discardProcurement();
              //   },
              //   onNextClicked: (){
              //     if(_formKey.currentState!.validate()){
              //     cont.setSelectedTabIndex(4);
              //   }
              // },
              //   onSaveClicked: (){},
              // )
            ],
          ),
        );
      }
    );
  }
}






class MobileProcurementTabContent extends StatefulWidget {
  const MobileProcurementTabContent({super.key});

  @override
  State<MobileProcurementTabContent> createState() => _MobileProcurementTabContentState();
}

class _MobileProcurementTabContentState extends State<MobileProcurementTabContent> {
  // String selectedItem = "USD";
  // TextEditingController _unitCostController = TextEditingController();
  // TextEditingController _decimalCostController = TextEditingController();
  // @override
  // void initState() {
  //   _unitCostController.text = "0";
  //   _decimalCostController.text = "0";
  //   super.initState();
  // }
  ProductController productController = Get.find();
  final _formKey=GlobalKey<FormState>();
  @override
  void initState() {
    // productController.getFieldsForCreateProductFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Form(
            key:_formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ReusableInputNumberField(
                      controller: unitCostController,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.3,
                      rowWidth:  MediaQuery.of(context).size.width * 0.5,
                      onChangedFunc: (){},validationFunc: (value) {
                      // if(value.isEmpty){
                      //   return 'required_field'.tr;
                      // }return null;
                    }
                      ,text: 'unit_cost'.tr,),
                    gapW6,
                    cont.isProductsInfoFetched
                            ? DropdownMenu<String>(
                          width: MediaQuery.of(context).size.width * 0.25,
                          controller: costCurrencyController,
                          requestFocusOnTap: false,
                          hintText:  cont.currenciesNames[cont.currenciesIds.indexOf(cont.selectedCurrencyId)],
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
                            cont.setSelectedCurrencyId(cont.currenciesIds[index]);
                          },
                        ):const Center(child: CircularProgressIndicator(),)

                  ],
                ),
                // gapH24,
                // ReusableInputNumberField(
                //   controller: decimalCostController,
                //   textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                //   rowWidth:  MediaQuery.of(context).size.width * 0.7,
                //   onChangedFunc: (){},validationFunc: (val){}
                //   ,text: 'decimal_cost'.tr,),
                // const Spacer(),
                // ReusableBTNsRow(
                //   onBackClicked: (){
                //     cont.setSelectedTabIndex(2);
                //   },
                //   onDiscardClicked: (){
                //     cont.discardProcurement();
                //   },
                //   onNextClicked: (){
                //     if(_formKey.currentState!.validate()){
                //       cont.setSelectedTabIndex(4);
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
