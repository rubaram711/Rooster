import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/products_controller.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import 'general_tab_content.dart';



TextEditingController itemNameController = TextEditingController();
TextEditingController showProductCurrencyController = TextEditingController();

class PosTabContent extends StatefulWidget {
  const PosTabContent({super.key, required this.isDesktop});
  final bool isDesktop;
  @override
  State<PosTabContent> createState() => _PosTabContentState();
}

class _PosTabContentState extends State<PosTabContent> {
  ProductController productController = Get.find();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // print(productController.packagesIds);
    // showProductCurrencyController.text='USD';
    itemNameController.text.isEmpty ? itemNameController.text=codeController.text: itemNameController.text=itemNameController.text;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<ProductController>(builder: (cont){
        return SizedBox(
          height: widget.isDesktop?MediaQuery.of(context).size.height * 0.7:MediaQuery.of(context).size.height * 0.5,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                gapH28,
                DialogTextField(
                  textEditingController: itemNameController,
                  text: '${'item_name'.tr}*',
                  rowWidth: widget.isDesktop? MediaQuery.of(context).size.width * 0.6: MediaQuery.of(context).size.width * 0.75,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.5,
                  validationFunc: (String value) {
                    if(value.isEmpty){
                      return 'required_field'.tr;
                    }
                    if(value.length>30 && value.isNotEmpty){
                      return 'name_30_characters'.tr;
                    }return null;
                  },
                ),
                gapH20,
                  Row(
                      children: [
                        Expanded(
                            child: ListTile(
                              title: Text('show_in_POS'.tr,
                                  style: const TextStyle(fontSize: 12)),
                              leading: Checkbox(
                                // checkColor: Colors.white,
                                // fillColor: MaterialStateProperty.resolveWith(getColor),
                                value: cont.isActiveInPosChecked,
                                onChanged: (bool? value) {
                                  cont.setIsActiveInPosChecked(value!);
                                },
                              ),
                            )),
                      ],
                    ),
                gapH20,
                Row(
                  children: [
                    SizedBox(
                        width:widget.isDesktop? MediaQuery.of(context).size.width * 0.15: MediaQuery.of(context).size.width * 0.4,
                        child: Text('${'the_currency_shown_in_pos'.tr}*')),
                    cont.isProductsInfoFetched
                        ?DropdownMenu<String>(
                      width: widget.isDesktop? MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.35,
                      requestFocusOnTap: false,
                      controller: showProductCurrencyController,
                      hintText: cont.currenciesNames[cont.currenciesIds.indexOf(cont.selectedShownCurrencyId)],
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
                        cont.setSelectedShownCurrencyId(cont.currenciesIds[index]);
                      },
                    ):loading(),
                  ],
                ),
                // const Spacer(),
                // ReusableBTNsRow(
                //   onBackClicked: (){
                //     cont.setSelectedTabIndex(7);
                //   },
                //   onDiscardClicked: (){
                //     cont.discardPos();
                //   },
                //   onNextClicked: (){},
                //   onSaveClicked: (){
                //     if(_formKey.currentState!.validate()){
                //       cont.isItUpdateProduct
                //           ? cont.updateProductCont(context)
                //           : cont.saveAndSendCreateProductOrder(context);
                //     }
                //   },
                //   isTheLastTab: true,
                // )
              ],
            ),
          ),
        );
      }
    );
  }

}



