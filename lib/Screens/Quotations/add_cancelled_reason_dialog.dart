import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Quotations/send_by_email.dart';
import 'package:rooster_app/Backend/Quotations/update_quotation.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/create_product_dialog.dart';
import 'package:rooster_app/Screens/Client/create_client_dialog.dart';
import 'package:rooster_app/Widgets/TransferWidgets/reusable_show_info_card.dart';
import 'package:rooster_app/Widgets/dialog_drop_menu.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/utils/image_picker_helper.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_drop_down_menu.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/constants.dart';
import '../../const/functions.dart';
import '../../const/urls.dart';
import '../Combo/combo.dart';
import 'create_new_quotation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

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
    );;
  }
}
