import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import 'package:rooster_app/const/Sizes.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Controllers/products_controller.dart';
import '../../../Widgets/table_item.dart';
import '../../../Widgets/table_title.dart';
import '../../../const/colors.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'general_tab_content.dart';

TextEditingController supplierCodeController = TextEditingController();
TextEditingController alternativeCodeController = TextEditingController();
TextEditingController barcodeController = TextEditingController();

class AltCodeTabContent extends StatefulWidget {
  const AltCodeTabContent({super.key});

  @override
  State<AltCodeTabContent> createState() => _AltCodeTabContentState();
}

class _AltCodeTabContentState extends State<AltCodeTabContent> {
  ProductController productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: GetBuilder<ProductController>(
        builder: (cont) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Primary.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TableTitle(
                      text: 'print_on_invoice'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Text(
                        'item_code'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TableTitle(
                      text: 'creation_date'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    TableTitle(
                      text: '',
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount:
                      cont.altCodesList.length, //products is data from back res
                  itemBuilder:
                      (context, index) => ReusableAltCodesAsRowInTable(
                        altCode: cont.altCodesList[index],
                        index: index,
                        altCodesListLength: cont.altCodesList.length,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

class ReusableAltCodesAsRowInTable extends StatefulWidget {
  const ReusableAltCodesAsRowInTable({
    super.key,
    required this.altCode,
    required this.index,
    required this.altCodesListLength,
  });
  final Map altCode;
  final int index;
  final int altCodesListLength;
  @override
  State<ReusableAltCodesAsRowInTable> createState() =>
      _ReusableAltCodesAsRowInTableState();
}

class _ReusableAltCodesAsRowInTableState
    extends State<ReusableAltCodesAsRowInTable> {
  GlobalKey accMoreKey = GlobalKey();
  GlobalKey addCodeKey = GlobalKey();
  DateTime now = DateTime.now();
  TextEditingController textEditingController = TextEditingController();
  HomeController homeController=Get.find();
  bool isChecked = false;
  @override
  void initState() {
    isChecked = widget.altCode['print_on_invoice'];
    textEditingController.text = widget.altCode['code'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal:homeController.isMobile.value?10: MediaQuery.of(context).size.width * 0.01,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(0)),
          ),
          child: Form(
            // key: formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: homeController.isMobile.value?140: MediaQuery.of(context).size.width * 0.1,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                      cont.altCodesList[widget.index]['print_on_invoice'] =
                          value;
                    },
                  ),
                ),
                SizedBox(
                  width:homeController.isMobile.value?140: MediaQuery.of(context).size.width * 0.35,
                  child:
                      widget.altCode['type'] == 'code'
                          ? Text(
                            codeController.text,
                            style: TextStyle(color: TypographyColor.textTable),
                          )
                          : Row(
                            children: [
                              widget.altCode['type'] == 'supplier_code'
                                  ? Image.asset(
                                    'assets/images/supplierCodeIcon.png',
                                  )
                                  : widget.altCode['type'] == 'alternative_code'
                                  ? Image.asset(
                                    'assets/images/alternativeCodeIcon.png',
                                  )
                                  : Image.asset(
                                    'assets/images/barcodeIcon.png',
                                  ),
                              gapW4,
                              SizedBox(
                                width:homeController.isMobile.value?100: MediaQuery.of(context).size.width * 0.15,
                                child: ReusableTextField(
                                  onChangedFunc: (value) {
                                    cont.altCodesList[widget.index]['code'] =
                                        value;
                                  },
                                  validationFunc: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'required_field'.tr;
                                    }
                                    return null;
                                  },
                                  hint: '',
                                  isPasswordField: false,
                                  textEditingController: textEditingController,
                                ),
                              ),
                            ],
                          ),
                ),
                TableItem(
                  text: DateFormat('yyyy-MM-dd').format(now),
                  width:homeController.isMobile.value?140: MediaQuery.of(context).size.width * 0.1,
                ),
                widget.index == widget.altCodesListLength - 1
                    ? SizedBox(
                      width: homeController.isMobile.value?140:MediaQuery.of(context).size.width * 0.1,
                      child: InkWell(
                        key: addCodeKey,
                        onTap: () {
                          // if (val == true) {
                          final RenderBox renderBox =
                              addCodeKey.currentContext?.findRenderObject()
                                  as RenderBox;
                          final Size size = renderBox.size;
                          final Offset offset = renderBox.localToGlobal(
                            Offset.zero,
                          );
                          showMenu(
                            context: context,
                            color: Colors.white, //TypographyColor.menuBg,
                            surfaceTintColor: Colors.white,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + size.height + 15,
                              offset.dx + size.width,
                              offset.dy + size.height,
                            ),
                            items: [
                              PopupMenuItem<String>(
                                value: '1',
                                onTap: () {
                                  setState(() {
                                    DateTime now = DateTime.now();
                                    String formattedDate = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(now);
                                    var p = {
                                      'print_on_invoice': false,
                                      'creation_date': formattedDate,
                                      'type': 'supplier_code',
                                      'code': '',
                                    };
                                    // altCodesList.addAll(p);
                                    cont.addToAltCodesList(p);
                                  });
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/supplierCodeIcon.png',
                                    ),
                                    gapW10,
                                    Text('supplier_code'.tr),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: '2',
                                onTap: () {
                                  DateTime now = DateTime.now();
                                  String formattedDate = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(now);
                                  setState(() {
                                    var p = {
                                      'print_on_invoice': false,
                                      'creation_date': formattedDate,
                                      'type': 'alternative_code',
                                      'code': '',
                                    };
                                    cont.addToAltCodesList(p);
                                  });
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/alternativeCodeIcon.png',
                                    ),
                                    gapW10,
                                    Text('alternative_code'.tr),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: '3',
                                onTap: () {
                                  DateTime now = DateTime.now();
                                  String formattedDate = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(now);
                                  setState(() {
                                    var p = {
                                      'print_on_invoice': false,
                                      'creation_date': formattedDate,
                                      'type': 'barcode',
                                      'code': '',
                                    };
                                    cont.addToAltCodesList(p);
                                  });
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/barcodeIcon.png',
                                    ),
                                    gapW10,
                                    Text('barcode'.tr),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_rounded,
                              color: Primary.primary,
                            ),
                            gapW6,
                            SizedBox(
                              width:homeController.isMobile.value?100: MediaQuery.of(context).size.width * 0.07,
                              child: Text(
                                'create_code'.tr,
                                style: TextStyle(
                                  color: TypographyColor.textTable,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : SizedBox(width:homeController.isMobile.value?140: MediaQuery.of(context).size.width * 0.1),
                widget.altCode['type'] == 'code'
                    ? SizedBox(width:homeController.isMobile.value?50: MediaQuery.of(context).size.width * 0.03)
                    : SizedBox(
                      width:homeController.isMobile.value?50: MediaQuery.of(context).size.width * 0.03,
                      child: InkWell(
                        key: accMoreKey,
                        onTap: () {
                          // if (val == true) {
                          final RenderBox renderBox =
                              accMoreKey.currentContext?.findRenderObject()
                                  as RenderBox;
                          final Size size = renderBox.size;
                          final Offset offset = renderBox.localToGlobal(
                            Offset.zero,
                          );
                          showMenu(
                            context: context,
                            color: Colors.white, //TypographyColor.menuBg,
                            surfaceTintColor: Colors.white,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + size.height + 15,
                              offset.dx + size.width,
                              offset.dy + size.height,
                            ),
                            items: [
                            ],
                          );
                        },
                        child: Icon(
                          Icons.more_horiz,
                          color: TypographyColor.titleTable,
                        ),
                      ),
                    ),
                widget.altCode['type'] == 'code'
                    ? SizedBox(width:homeController.isMobile.value?50: MediaQuery.of(context).size.width * 0.03)
                    : SizedBox(
                      width:homeController.isMobile.value?50: MediaQuery.of(context).size.width * 0.03,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            cont.removeFromAltCodesList(widget.index);
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
        );
      },
    );
  }
}

class MobileAltCodeTabContent extends StatefulWidget {
  const MobileAltCodeTabContent({super.key});

  @override
  State<MobileAltCodeTabContent> createState() =>
      _MobileAltCodeTabContentState();
}

class _MobileAltCodeTabContentState extends State<MobileAltCodeTabContent> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return SingleChildScrollView(
          child: Row(
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            TableTitle(
                              text: 'print_on_invoice'.tr,
                              width: 140,
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                'item_code'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TableTitle(
                              text: 'creation_date'.tr,
                              width: 140,
                            ),
                            TableTitle(
                              text: '',
                              width: 140,
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            SizedBox(
                              width:50,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            cont.altCodesList.length,
                            (index) => ReusableAltCodesAsRowInTable(
                              altCode: cont.altCodesList[index],
                              index: index,
                              altCodesListLength: cont.altCodesList.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


