import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import 'package:rooster_app/const/sizes.dart';

class UpdateItem extends StatefulWidget {
  const UpdateItem({super.key, required this.quantity});
  final String quantity;
  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  TextEditingController qtycontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboController>(
      builder:
          (cont) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                gapH28,
                DialogTextField(
                  validationFunc: () {},
                  text: "Quantity",
                  rowWidth: MediaQuery.of(context).size.width * 0.3,
                  textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                  textEditingController: qtycontroller,
                ),
                gapH28,
                ReusableButtonWithColor(
                  btnText: 'Update'.tr,
                  onTapFunction: () {},
                  width: 200,
                  height: 35,
                ),
              ],
            ),
          ),
    );
  }
}
