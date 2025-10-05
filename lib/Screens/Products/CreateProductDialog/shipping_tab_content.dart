import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

TextEditingController unitsSuffix = TextEditingController();
TextEditingController setsSuffix = TextEditingController();
TextEditingController supersetSuffix = TextEditingController();
TextEditingController paletteSuffix = TextEditingController();
TextEditingController containerSuffix = TextEditingController();
TextEditingController unitsQuantity = TextEditingController();
TextEditingController setsQuantity = TextEditingController();
TextEditingController supersetQuantity = TextEditingController();
TextEditingController paletteQuantity = TextEditingController();
TextEditingController containerQuantity = TextEditingController();
TextEditingController decimalQuantityController = TextEditingController();
TextEditingController packageController = TextEditingController();
TextEditingController weightController = TextEditingController();
TextEditingController weightTextEditingController = TextEditingController();
TextEditingController volumeController = TextEditingController();
TextEditingController volumeTextEditingController = TextEditingController();
TextEditingController defaultTransactionPackageController =
TextEditingController();

class ShippingTabContent extends StatefulWidget {
  const ShippingTabContent({super.key, required this.isDesktop});
  final bool isDesktop;
  @override
  State<ShippingTabContent> createState() => _ShippingTabContentState();
}

class _ShippingTabContentState extends State<ShippingTabContent> {
  final TextEditingController controller = TextEditingController();

  // String selectedPackageType='units'.tr;
  // String? selectedItem = 'units'.tr;
  // List<String> packagesNames = [
  //   'units'.tr,
  //   'sets'.tr,
  //   'supersets'.tr,
  //   'palette'.tr,
  //   'container'.tr
  // ];
  // List packagesIds = ['1', '2', '3', '4', '5'];
  ProductController productController = Get.find();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // print(productController.productsList[productController.selectedProductIndex]['packageType']);
    if (productController.isItUpdateProduct) {
      productController.selectedPackageId =
      '${productController.productsList[productController.selectedProductIndex]['packageType']}';
      int index = productController.packagesIds.indexOf(
        '${productController.productsList[productController.selectedProductIndex]['defaultTransactionPackageType']}',
      );
      defaultTransactionPackageController.text =
      productController.packagesNames[index];
    }
    // print(productController.packagesIds);

    // packageController.text =
    //     productController.packagesNames[productController.packagesIds.indexOf(productController.selectedPackageId)];
    // defaultTransactionPackageController.text =
    // productController.packagesNames[productController.packagesIds.indexOf(productController.selectedPackagesId)];
    weightController.text =
    packageController.text.isEmpty || unitsSuffix.text.isEmpty
        ? ''
        : '${packageController.text}/${unitsSuffix.text}';
    volumeController.text =
    packageController.text.isEmpty || unitsSuffix.text.isEmpty
        ? ''
        : '${packageController.text}/${unitsSuffix.text}';
    super.initState();
  }

  String? selectedValue = '';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        // print('selectedPackageId3');
        // print('${cont.selectedPackageId}');
        // print('${packageController.text}');
        return SizedBox(
          height:
          widget.isDesktop
              ? MediaQuery.of(context).size.height * 0.7
              : MediaQuery.of(context).size.height * 0.5,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.isDesktop ? gapH28 : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 0.0,
                        direction: Axis.horizontal,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width:
                                widget.isDesktop
                                    ? MediaQuery.of(context).size.width *
                                    0.13
                                    : MediaQuery.of(context).size.width *
                                    0.3,
                                child: Text('${'package_type'.tr}*'),
                              ),
                              DropdownMenu<String>(
                                controller: packageController,
                                width:
                                widget.isDesktop
                                    ? (MediaQuery.of(context).size.width *
                                    0.19) +
                                    10
                                    : MediaQuery.of(context).size.width *
                                    0.4,
                                requestFocusOnTap: false,
                                hintText: 'units'.tr,
                                inputDecorationTheme: InputDecorationTheme(
                                  hintStyle: TextStyle(color: Colors.grey[300]),
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
                                dropdownMenuEntries:
                                cont.packagesNames
                                    .map<DropdownMenuEntry<String>>((
                                    String option,
                                    ) {
                                  return DropdownMenuEntry<String>(
                                    value: option,
                                    label: option,
                                  );
                                })
                                    .toList(),
                                onSelected: (String? val) {
                                  setState(() {
                                    weightController.text =
                                    '${packageController.text}/${unitsSuffix.text}';
                                    volumeController.text =
                                    '${packageController.text}/${unitsSuffix.text}';
                                    selectedValue = weightController.text;
                                  });
                                  // setState(() {
                                  defaultTransactionPackageController.text =
                                  cont.packagesNames[0];
                                  cont.setSelectedDefaultTransactionPackageId(
                                    '1',
                                  );
                                  // selectedPackageType=val!;
                                  int index = cont.packagesNames.indexOf(val!);
                                  cont.setSelectedPackageId(
                                    cont.packagesIds[index],
                                  );
                                  // });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: widget.isDesktop ? 50.w : 200.w,
                            child: Text('weight'.tr),
                          ),
                          gapW10,
                          packageController.text.isNotEmpty ||
                              unitsSuffix.text.isNotEmpty
                              ? DropdownButton<String>(
                            value: selectedValue,
                            items: [
                              DropdownMenuItem(
                                value: selectedValue,
                                child: Text('$selectedValue'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              // Since there's only one item, this may not change
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                          )
                              : DropdownMenu<String>(
                            controller: weightController,
                            width:
                            widget.isDesktop
                                ? (MediaQuery.of(context).size.width *
                                0.07) +
                                10
                                : MediaQuery.of(context).size.width *
                                0.4,
                            requestFocusOnTap: false,
                            hintText: 'un'.tr,
                            inputDecorationTheme: InputDecorationTheme(
                              hintStyle: TextStyle(color: Colors.grey[300]),
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
                            dropdownMenuEntries:
                            cont.packagesNames
                                .map<DropdownMenuEntry<String>>((
                                String option,
                                ) {
                              return DropdownMenuEntry<String>(
                                value: option,
                                label: option,
                              );
                            })
                                .toList(),
                            onSelected: (String? val) {
                              // setState(() {
                              weightController.text = val!;
                              // defaultTransactionPackageController.text =
                              //     cont.packagesNames[0];
                              // cont.setSelectedDefaultTransactionPackageId('1');
                              // selectedPackageType=val!;
                              // int index = cont.packagesNames.indexOf(val);
                              // cont.setSelectedPackageId(
                              //   cont.packagesIds[index],
                              // );
                              // });
                            },
                          ),
                          gapW10,
                          SizedBox(
                            width: 150.w,
                            child: ReusableTextField(
                              onChangedFunc: (String? val) {
                                weightTextEditingController.text = val!;
                              },
                              validationFunc: (value) {
                                if (value!.isEmpty ||
                                    double.parse(value) <= 0) {
                                  return 'must be >0';
                                }
                                return null;
                              },
                              hint: "",
                              isPasswordField: false,
                              textEditingController:
                              weightTextEditingController,
                            ),
                          ),
                          gapW10,
                          SizedBox(
                            width:
                            widget.isDesktop
                                ? MediaQuery.of(context).size.width * 0.03
                                : MediaQuery.of(context).size.width * 0.05,
                            child: Text('kg'.tr),
                          ),
                        ],
                      ),

                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: widget.isDesktop ? 50.w : 200.w,
                            child: Text('volume'.tr),
                          ),
                          gapW10,
                          packageController.text.isNotEmpty ||
                              unitsSuffix.text.isNotEmpty
                              ?
                          // Container(
                          //   width: MediaQuery.of(context).size.width * 0.07,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.all(
                          //       Radius.circular(5),
                          //     ),
                          //     border: Border.all(
                          //       width: 1.0,
                          //       color: Primary.primary.withAlpha(
                          //         (0.2 * 255).toInt(),
                          //       ),
                          //     ),
                          //   ),
                          //   child:
                          DropdownButton<String>(
                            value: selectedValue,
                            items: [
                              DropdownMenuItem(
                                value: selectedValue,
                                child: Text('$selectedValue'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              // Since there's only one item, this may not change
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                          ) //, )
                              : DropdownMenu<String>(
                            controller: volumeController,
                            width:
                            widget.isDesktop
                                ? (MediaQuery.of(context).size.width *
                                0.07) +
                                10
                                : MediaQuery.of(context).size.width *
                                0.4,
                            requestFocusOnTap: false,
                            hintText: 'un'.tr,
                            inputDecorationTheme: InputDecorationTheme(
                              hintStyle: TextStyle(color: Colors.grey[300]),
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
                            dropdownMenuEntries:
                            cont.packagesNames
                                .map<DropdownMenuEntry<String>>((
                                String option,
                                ) {
                              return DropdownMenuEntry<String>(
                                value: option,
                                label: option,
                              );
                            })
                                .toList(),
                            onSelected: (String? val) {
                              // setState(() {
                              volumeController.text = val!;
                              // defaultTransactionPackageController.text =
                              //     cont.packagesNames[0];
                              // cont.setSelectedDefaultTransactionPackageId('1');
                              // selectedPackageType=val!;
                              // int index = cont.packagesNames.indexOf(val!);
                              // cont.setSelectedPackageId(
                              //   cont.packagesIds[index],
                              // );
                              // });
                            },
                          ),
                          gapW10,
                          SizedBox(
                            width: 150.w,
                            child: ReusableTextField(
                              onChangedFunc: (String? val) {
                                volumeTextEditingController.text = val!;
                              },
                              validationFunc: (value) {
                                if (value!.isEmpty ||
                                    double.parse(value) <= 0) {
                                  return 'must be >0';
                                }
                                return null;
                              },
                              hint: "",
                              isPasswordField: false,
                              textEditingController:
                              volumeTextEditingController,
                            ),
                          ),
                          gapW10,
                          SizedBox(
                            width:
                            widget.isDesktop
                                ? MediaQuery.of(context).size.width * 0.03
                                : MediaQuery.of(context).size.width * 0.05,
                            child: Text('m³'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  gapH20,
                  // optionsContent[selectedItem] ?? const SizedBox(),
                  TextFieldInShipping(
                    textEditingController: unitsSuffix,
                    quantityTextEditingController: unitsQuantity,
                    isUnitTextField: true,
                    isDesktop: widget.isDesktop,
                    text: '${'unit_name'.tr}*',
                    prefix: 'unit_name_prefix'.tr,
                    suffix: '',
                    validationFunc: (value) {
                      if (value.isEmpty) {
                        return 'required_field'.tr;
                      }
                      return null;
                    },
                    onChangedFunc: (val) {
                      cont.setUnitsSuffixText(val);
                      setState(() {
                        weightController.text =
                        '${packageController.text}/${unitsSuffix.text}';
                        volumeController.text =
                        '${packageController.text}/${unitsSuffix.text}';
                        selectedValue = weightController.text;
                      });
                    },
                    onSecondTextFieldChangedFunc: () {},
                  ),
                  gapH20,
                  // ( selectedItem=='sets'.tr|| selectedItem=='supersets'.tr|| selectedItem=='palette'.tr|| selectedItem=='container'.tr )
                  (cont.selectedPackageId == '2' ||
                      cont.selectedPackageId == '3' ||
                      cont.selectedPackageId == '4' ||
                      cont.selectedPackageId == '5')
                      ? Column(
                    children: [
                      TextFieldInShipping(
                        textEditingController: setsSuffix,
                        quantityTextEditingController: setsQuantity,
                        isDesktop: widget.isDesktop,
                        text: '${'sets_name'.tr}*',
                        prefix: 'sets_name_prefix'.tr,
                        suffix:
                        '${cont.unitsSuffixText} ${'per'.tr} ${setsSuffix.text}',
                        validationFunc: (value) {
                          if (value.isEmpty) {
                            return 'required_field'.tr;
                          }
                          return null;
                        },
                        onChangedFunc: (val) {
                          cont.setSetsSuffixText(val);
                        },
                        onSecondTextFieldChangedFunc: () {},
                      ),
                      gapH20,
                    ],
                  )
                      : const SizedBox(),

                  // (selectedItem=='supersets'.tr|| selectedItem=='palette'.tr|| selectedItem=='container'.tr )
                  (cont.selectedPackageId == '3' ||
                      cont.selectedPackageId == '4' ||
                      cont.selectedPackageId == '5')
                      ? Column(
                    children: [
                      TextFieldInShipping(
                        textEditingController: supersetSuffix,
                        quantityTextEditingController: supersetQuantity,
                        isDesktop: widget.isDesktop,
                        text: '${'supersets_name'.tr}*',
                        prefix: 'supersets_name_prefix'.tr,
                        suffix:
                        '${setsSuffix.text} ${'per'.tr} ${supersetSuffix.text}',
                        validationFunc: (value) {
                          if (value.isEmpty) {
                            return 'required_field'.tr;
                          }
                          return null;
                        },
                        onChangedFunc: (val) {
                          cont.setSupersetsSuffixText(val);
                        },
                        onSecondTextFieldChangedFunc: () {},
                      ),
                      gapH20,
                    ],
                  )
                      : const SizedBox(),
                  // (selectedItem=='palette'.tr|| selectedItem=='container'.tr )
                  (cont.selectedPackageId == '4' ||
                      cont.selectedPackageId == '5')
                      ? Column(
                    children: [
                      TextFieldInShipping(
                        textEditingController: paletteSuffix,
                        quantityTextEditingController: paletteQuantity,
                        isDesktop: widget.isDesktop,
                        text: '${'palette_name'.tr}*',
                        prefix: 'palette_name_prefix'.tr,
                        suffix:
                        '${supersetSuffix.text} ${'per'.tr} ${paletteSuffix.text}',
                        validationFunc: (value) {
                          if (value.isEmpty) {
                            return 'required_field'.tr;
                          }
                          return null;
                        },
                        onChangedFunc: (val) {
                          cont.setPaletteSuffixText(val);
                        },
                        onSecondTextFieldChangedFunc: () {},
                      ),
                      gapH20,
                    ],
                  )
                      : const SizedBox(),

                  // selectedItem=='container'.tr
                  cont.selectedPackageId == '5'
                      ? Column(
                    children: [
                      TextFieldInShipping(
                        textEditingController: containerSuffix,
                        quantityTextEditingController: containerQuantity,
                        isDesktop: widget.isDesktop,
                        text: '${'container_name'.tr}*',
                        prefix: 'container_name_prefix'.tr,
                        suffix:
                        '${paletteSuffix.text} ${'per'.tr} ${containerSuffix.text}',
                        validationFunc: (value) {
                          if (value.isEmpty) {
                            return 'required_field'.tr;
                          }
                          return null;
                        },
                        onChangedFunc: (val) {
                          cont.setContainerSuffixText(val);
                        },
                        onSecondTextFieldChangedFunc: () {},
                      ),
                      gapH20,
                    ],
                  )
                      : const SizedBox(),
                  gapH20,
                  Row(
                    children: [
                      SizedBox(
                        width:
                        widget.isDesktop
                            ? MediaQuery.of(context).size.width * 0.13
                            : MediaQuery.of(context).size.width * 0.3,
                        child: Text('${'default_trans_packaging'.tr}*'),
                      ),
                      DropdownMenu<String>(
                        controller: defaultTransactionPackageController,
                        width:
                        widget.isDesktop
                            ? (MediaQuery.of(context).size.width * 0.19) +
                            10
                            : MediaQuery.of(context).size.width * 0.4,
                        requestFocusOnTap: false,
                        hintText: 'units'.tr,
                        inputDecorationTheme: InputDecorationTheme(
                          // filled: true,
                          hintStyle: TextStyle(color: Colors.grey[300]),
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
                        dropdownMenuEntries:
                        cont.packagesNames
                            .sublist(
                          0,
                          cont.packagesIds.indexOf(
                            cont.selectedPackageId,
                          ) +
                              1,
                        )
                            .map<DropdownMenuEntry<String>>((
                            String option,
                            ) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                          );
                        })
                            .toList(),
                        onSelected: (String? val) {
                          // setState(() {
                          int index = cont.packagesNames.indexOf(val!);
                          cont.setSelectedDefaultTransactionPackageId(
                            cont.packagesIds[index],
                          );
                          // });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TextFieldInShipping extends StatelessWidget {
  const TextFieldInShipping({
    super.key,
    required this.text,
    required this.prefix,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.suffix,
    required this.onSecondTextFieldChangedFunc,
    required this.isDesktop,
    required this.textEditingController,
    required this.quantityTextEditingController,
    this.isUnitTextField = false,
  });
  final String text;
  final String prefix;
  final Function onChangedFunc;
  final Function onSecondTextFieldChangedFunc;
  final Function validationFunc;
  final String suffix;
  final bool isDesktop;
  final bool isUnitTextField;
  final TextEditingController textEditingController;
  final TextEditingController quantityTextEditingController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: isDesktop
      //     ? MediaQuery.of(context).size.width * 0.42
      //     : MediaQuery.of(context).size.width * 0.8,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width:
            isDesktop
                ? MediaQuery.of(context).size.width * 0.13
                : MediaQuery.of(context).size.width * 0.3,
            child: Text(text),
          ),
          Row(
            children: [
              SizedBox(
                width:
                isDesktop
                    ? MediaQuery.of(context).size.width * 0.04
                    : MediaQuery.of(context).size.width * 0.15,
                child: TextFormField(
                  controller: textEditingController,
                  cursorColor: Colors.black,
                  // text: textEditingController.text.toUpperCase(),
                  // textCapitalization: TextCapitalization.words,
                  // keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 2),
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
                    errorStyle: const TextStyle(fontSize: 10.0),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      borderSide: BorderSide(width: 1, color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    return validationFunc(value);
                  },
                  onChanged: (value) {
                    textEditingController.value = textEditingController.value
                        .copyWith(
                      text: _capitalizeText(value),
                      selection: TextSelection.collapsed(
                        offset: textEditingController.text.length,
                      ),
                    );
                    onChangedFunc(value);
                  },
                  // inputFormatters: <TextInputFormatter>[
                  //   FilteringTextInputFormatter.allow(RegExp('[A-Z]')),
                  // ]
                ),
              ),
              isDesktop ? gapW10 : gapW4,
              SizedBox(
                width:
                isDesktop
                    ? MediaQuery.of(context).size.width * 0.15
                    : MediaQuery.of(context).size.width * 0.15,
                child:
                isUnitTextField
                    ? const SizedBox()
                    : TextFormField(
                  controller: quantityTextEditingController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    contentPadding:
                    isDesktop
                        ? const EdgeInsets.fromLTRB(20, 0, 25, 5)
                        : const EdgeInsets.fromLTRB(5, 0, 5, 5),
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
                    errorStyle: const TextStyle(fontSize: 10.0),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(9),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  validator: (String? value) {
                    // return validationFunc(value);
                    if (value!.isEmpty) {
                      return 'required_field'.tr;
                    } else if (double.parse(value) <= 0) {
                      return 'Value must be >0';
                    }
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    // NumberFormatter(),
                  ],
                  // onChanged: (value) => onSecondTextFieldChangedFunc(value),
                ),
              ),
              isDesktop ? gapW24 : gapW4,
              SizedBox(
                width:
                isDesktop
                    ? MediaQuery.of(context).size.width * 0.085
                    : MediaQuery.of(context).size.width * 0.1,
                child: Text(suffix.toUpperCase()),
              ), //todo
            ],
          ),
        ],
      ),
    );
  }

  String _capitalizeText(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.toUpperCase();
  }
}
