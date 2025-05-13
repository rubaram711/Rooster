import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Controllers/payment_terms_controller.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';



class PaymentTermsDialogContent extends StatefulWidget {
  const PaymentTermsDialogContent({super.key});

  @override
  State<PaymentTermsDialogContent> createState() => _PaymentTermsDialogContentState();
}

class _PaymentTermsDialogContentState extends State<PaymentTermsDialogContent> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  int selectedTabIndex = 0;
  bool isClicked = false;
  String name = '';
  String desc = '';
  final _formKey = GlobalKey<FormState>();
  PaymentTermsController paymentTermsController = Get.find();
  HomeController homeController  = Get.find();
  @override
  void initState() {
    paymentTermsController.getPaymentTermsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height:homeController.isMobile.value ?MediaQuery.of(context).size.height * 0.7: MediaQuery.of(context).size.height * 0.9,
      margin:  EdgeInsets.symmetric(horizontal: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05:50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTitle(text: 'payment_terms'.tr),
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
          _generalTabInPaymentTerms(),
          const Spacer(),
          isClicked
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      descriptionController.clear();
                      nameController.clear();
                      name = '';
                      desc = '';
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
                    // if(_formKey.currentState!.validate()){
                    // var p = await addDiscounts(name, desc);
                    // if (p['success'] == true) {
                    //   // Get.back();
                    //   paymentTermsController.getPaymentTermsFromBack();
                    //   CommonWidgets.snackBar('', p['message']);
                    //   name = '';
                    //   desc = '';
                    //   nameController.clear();
                    //   descriptionController.clear();
                    // } else {
                    //   CommonWidgets.snackBar('error', p['message']);
                    // }
                  },
                  width: 100,
                  height: 35),
            ],
          )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _generalTabInPaymentTerms() {
    return GetBuilder<PaymentTermsController>(builder: (cont) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?5: 40, vertical: 15),
            decoration: BoxDecoration(
                color: Primary.primary,
                borderRadius: const BorderRadius.all(Radius.circular(6))),
            child: Row(
              children: [
                TableTitle(
                  text: 'name'.tr,
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                ),
                TableTitle(
                  text: 'description'.tr,
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.4,
                ),
              ],
            ),
          ),
          isClicked
              ? Container(
            padding:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?5: 40),
            height: 55,
            decoration: BoxDecoration(
                color: Primary.p10,
                borderRadius: const BorderRadius.all(Radius.circular(0))),
            child: Center(
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                    child: Center(
                      child: SizedBox(
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.15,
                        child: ReusableTextField(
                          textEditingController: nameController,
                          onChangedFunc: (val) {
                            setState(() {
                              name = val;
                            });
                          },
                          hint: '',
                          validationFunc: (value) {},
                          isPasswordField: false,
                          isEnable: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.4,
                    child: Center(
                      child: SizedBox(
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width * 0.35,
                        child: ReusableTextField(
                          textEditingController: descriptionController,
                          onChangedFunc: (val) {
                            setState(() {
                              desc = val;
                            });
                          },
                          hint: '',
                          validationFunc: (value) {},
                          isPasswordField: false,
                          isEnable: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox(),
          cont.isPaymentTermsFetched
              ? Container(
            color: Colors.white,
            height: cont.paymentTermsList.length * 55,
            child: ListView.builder(
              itemCount: cont
                  .paymentTermsList.length, //products is data from back res
              itemBuilder: (context, index) => paymentTermAsRowInTable(
                cont.paymentTermsList[index],
                index,
              ),
            ),
          )
              : const Center(
            child: CircularProgressIndicator(),
          ),
          gapH10,
          isClicked
              ? const SizedBox()
              : ReusableAddCard(
            text: 'new_payment_term'.tr,
            onTap: () {
              setState(() {
                isClicked = true;
              });
            },
          ),
        ],
      );
    });
  }

  paymentTermAsRowInTable(Map info, int index) {
    return GetBuilder<PaymentTermsController>(builder: (cont) {
      return InkWell(
        onDoubleTap: () {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  elevation: 0,
                  content: UpdatePaymentTermDialog(
                    index: index,
                  )));
        },
        child: Container(
          height: 55,
          padding:   EdgeInsets.symmetric(
            horizontal:homeController.isMobile.value?5: 40,
          ),
          decoration: BoxDecoration(
              color: (index % 2 != 0) ? Primary.p10 : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(0))),
          child: Center(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TableItem(
                  text: '${info['name'] ?? ''}',
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.2,
                ),
                TableItem(
                  text: '${info['description']}',
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.4,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: InkWell(
                    onTap: () async {
                      // var res = await deleteDiscount(
                      //     '${cont.paymentTermsList[index]['id']}');
                      // var p = json.decode(res.body);
                      // if (res.statusCode == 200) {
                      //   CommonWidgets.snackBar('Success', p['message']);
                      //   // warehouseController.resetValues();
                      //   cont.getPaymentTermsFromBack();
                      // } else {
                      //   CommonWidgets.snackBar('error', p['message']);
                      // }
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
      );
    });
  }

  newPaymentTermAsRowInTable(Map altCode, int index, int altCodesListLength) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Form(
        key: _formKey,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
              child: ReusableTextField(
                textEditingController: nameController,
                onChangedFunc: (val) {},
                hint: '',
                validationFunc: (String val) {
                  if (val.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
                isPasswordField: false,
                isEnable: true,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.07,
              child: ReusableTextField(
                textEditingController: descriptionController,
                onChangedFunc: (val) {},
                hint: '',
                validationFunc: (String val) {
                  if (val.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
                isPasswordField: false,
                isEnable: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class UpdatePaymentTermDialog extends StatefulWidget {
  const UpdatePaymentTermDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdatePaymentTermDialog> createState() => _UpdatePaymentTermDialogState();
}

class _UpdatePaymentTermDialogState extends State<UpdatePaymentTermDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  PaymentTermsController paymentTermsController = Get.find();
  @override
  void initState() {
    nameController.text =
    '${paymentTermsController.paymentTermsList[widget.index]['name'] ?? ''}';
    descController.text =
    '${paymentTermsController.paymentTermsList[widget.index]['description']}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        // width: Sizes.deviceWidth*0.2,
        height: 250,
        // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                rowWidth: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                validationFunc: (String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
              ),
              gapH16,
              DialogNumericTextField(
                textEditingController: descController,
                text: '${'description'.tr}*',
                rowWidth: MediaQuery.of(context).size.width * 0.3,
                textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                validationFunc: (String value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          nameController.text =
                          '${paymentTermsController.paymentTermsList[widget.index]['name'] ?? ''}';
                          descController.text =
                          '${paymentTermsController.paymentTermsList[widget.index]['description']}';
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
                        if (_formKey.currentState!.validate()) {
                          // var p = await updateDiscount(//todo
                          //     '${paymentTermsController.paymentTermsList[widget.index]['id']}',
                          //     nameController.text,
                          //     descController.text);
                          // if (p['success'] == true) {
                          //   Get.back();
                          //   CommonWidgets.snackBar('success'.tr, p['message']);
                          //   paymentTermsController.getPaymentTermsFromBack();
                          // } else {
                          //   CommonWidgets.snackBar('error', p['message']);
                          // }
                        }
                      },
                      width: 100,
                      height: 35),
                ],
              ),
            ],
          ),
        ));
  }
}






