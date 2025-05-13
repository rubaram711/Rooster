import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Backend/ProductsBackend/edit_price_of_product.dart';
import '../../Backend/get_currencies.dart';
import '../../Controllers/products_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/colors.dart';
import '../../const/sizes.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EditPriceDialog extends StatefulWidget {
  const EditPriceDialog({super.key, required this.id, this.isMobile = false, required this.product});
  final String id;
  final bool isMobile;
  final Map product;
  @override
  State<EditPriceDialog> createState() => _EditPriceDialogState();
}

class _EditPriceDialogState extends State<EditPriceDialog> {
  TextEditingController priceController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController currencyController = TextEditingController();

  List<String> currenciesNamesList = [];
  List currenciesIdsList = [];
  String selectedCurrencyId = '';
  String? selectedItem = '';
  bool isDataFetched = false;
  getCurrenciesFromBackend() async {
    var p = await getCurrencies();
    if ('$p' != '[]') {
      setState(() {
        for (var c in p['currencies']) {
          currenciesNamesList.add('${c['name']}');
          currenciesIdsList.add('${c['id']}');
        }
        isDataFetched = true;
        // selectedCurrencyId = currenciesIdsList[0];
      });
    }
  }

  ProductController productController = Get.find();
  @override
  void initState() {
    getCurrenciesFromBackend();
setState(() {
  priceController.text='${widget.product['unitPrice']??''}';
  selectedCurrencyId='${widget.product['priceCurrency']['id']??'1'}';
});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          // width: Sizes.deviceWidth*0.2,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTitle(text: 'edit_price'.tr),
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
              gapH40,
              ReusableInputNumberField(
                controller: priceController,
                textFieldWidth: widget.isMobile
                    ? MediaQuery.of(context).size.width * 0.2
                    : MediaQuery.of(context).size.width * 0.15,
                rowWidth: widget.isMobile
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.25,
                onChangedFunc: (value) {},
                validationFunc: (String value) {},
                text: '${'new_price'.tr}*',
              ),
              gapH16,
              SizedBox(
                width: widget.isMobile
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'currency'.tr}*'),
                    isDataFetched
                        ? DropdownMenu<String>(
                            width: widget.isMobile
                                ? MediaQuery.of(context).size.width * 0.2
                                : MediaQuery.of(context).size.width * 0.15,
                            // requestFocusOnTap: false,
                            enableSearch: true,
                            controller: currencyController,
                            hintText: currenciesNamesList[
                                currenciesIdsList.indexOf(selectedCurrencyId)],
                            inputDecorationTheme: InputDecorationTheme(
                              // filled: true,
                              // hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 0, 25, 5),
                              // outlineBorder: BorderSide(color: Colors.black,),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                                    width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                                    width: 2),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(9)),
                              ),
                            ),
                            // menuStyle: ,
                            menuHeight: 250,
                            dropdownMenuEntries: currenciesNamesList
                                .map<DropdownMenuEntry<String>>((String option) {
                              return DropdownMenuEntry<String>(
                                value: option,
                                label: option,
                              );
                            }).toList(),
                            enableFilter: true,
                            onSelected: (String? val) {
                              setState(() {
                                selectedItem = val!;
                                var index = currenciesNamesList.indexOf(val);
                                selectedCurrencyId = currenciesIdsList[index];
                              });
                            },
                          )
                        : loading(),
                  ],
                ),
              ),
              gapH16,
              SizedBox(
                width: widget.isMobile
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'start_date'.tr}*',
                    ),
                    DialogDateTextField(
                      onChangedFunc: (value) {},
                      onDateSelected: (value) {
                        cont.setStartDate (value) ;
                        startDateController.text=value;
                      },
                      textEditingController: startDateController,
                      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      textFieldWidth: widget.isMobile
                          ? MediaQuery.of(context).size.width * 0.2
                          : MediaQuery.of(context).size.width * 0.15,
                      validationFunc: (value) {},
                    ),
                  ],
                ),
              ),
              gapH16,
              SizedBox(
                width: widget.isMobile
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'start_time'.tr}*',
                    ),
                    DialogTimeTextField(
                      onChangedFunc: (value) {},
                      onTimeSelected: (value) {
                        cont.setStartTime(value);

                      },
                      textEditingController: startTimeController,
                      text: DateFormat.Hm().format(DateTime.now()),
                      textFieldWidth: widget.isMobile
                          ? MediaQuery.of(context).size.width * 0.2
                          : MediaQuery.of(context).size.width * 0.15,
                      validationFunc: (value) {},
                    ),
                  ],
                ),
              ),
              gapH32,
              ReusableButtonWithColor(
                  btnText: 'apply'.tr,
                  radius: 9,
                  onTapFunction: () async {
                    // if(priceController.text.isNotEmpty || startDate.isNotEmpty || startTime.isNotEmpty || selectedCurrencyId != '') {
                    var res = await editPriceOfProduct(
                        cont.startDate.isEmpty && cont.startTime.isEmpty
                            ? '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${DateFormat.Hms().format(DateTime.now())}'
                            : cont.startDate.isEmpty && cont.startTime.isNotEmpty
                                ? '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${cont.startTime}:00'
                                : cont.startDate.isNotEmpty && cont.startTime.isEmpty
                                    ? '${cont.startDate} ${DateFormat.Hms().format(DateTime.now())}'
                                    : '${cont.startDate} ${cont.startTime}:00',
                        priceController.text,
                        widget.id,
                        selectedCurrencyId);
                    Get.back();
                    if (res['success'] == true) {
                      productController.getAllProductsFromBack();
                      CommonWidgets.snackBar(
                          'Success', res['message']);
                    } else {
                      CommonWidgets.snackBar('error',res['message']);
                    }
                    // }else{
                    //   CommonWidgets.snackBar('error', 'All fields are required');
                    // }
                  },
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 50)
            ],
          ),
        );
      }
    );
  }
}
