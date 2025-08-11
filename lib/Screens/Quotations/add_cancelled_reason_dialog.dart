import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';

class AddCancelledReasonDialog extends StatefulWidget {
  const AddCancelledReasonDialog({super.key, required this.func});
final Function func;
  @override
  State<AddCancelledReasonDialog> createState() => _AddCancelledReasonDialogState();
}

class _AddCancelledReasonDialogState extends State<AddCancelledReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController cancelledReasonController = TextEditingController();

  @override
  void initState() {
    cancelledReasonController.clear();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.32,
      // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GetBuilder<QuotationController>(builder: (quotationCont) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DialogTitle(text: 'enter_cancelled_reason'.tr),
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
                gapH32,
                ReusableTextField
                  (onChangedFunc: (value){
                },
                    validationFunc:  (String? value){
                      if(value!.isEmpty){return 'required_field'.tr;}return null;
                    },
                    hint: '',
                    isPasswordField: false,
                    textEditingController: cancelledReasonController),
                gapH20,
                ReusableButtonWithColor(
                    width: MediaQuery.of(context).size.width ,
                    height: 50,
                    btnText: 'apply'.tr,
                    radius: 9,
                    onTapFunction: () async {
                      if (_formKey.currentState!.validate()) {
                        widget.func(cancelledReasonController.text);
                      }}
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
