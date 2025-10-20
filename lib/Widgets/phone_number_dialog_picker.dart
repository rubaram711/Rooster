import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/country_picker_dialog.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:get/get.dart';
import '../Controllers/home_controller.dart';
import '../const/colors.dart';

class PhoneDialogTextField2 extends StatelessWidget {
  const PhoneDialogTextField2({
    super.key,
    required this.text,
    required this.rowWidth,
    required this.textFieldWidth,
    required this.textEditingController,
    this.hint = '',
    this.isPassword = false,
    this.globalKey,
    this.read = false,
    this.onTap, // 🔹 Optional callback for read-only tap
    this.onChangedFunc,
    this.onValidateFunc,
  });

  final String text;
  final String hint;
  final double rowWidth;
  final double textFieldWidth;
  final TextEditingController textEditingController;
  final bool isPassword;

  final GlobalKey? globalKey;
  final bool read;
  final VoidCallback? onTap;

  final Function(String)? onChangedFunc;
  final Function(String)? onValidateFunc;

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();

    return SizedBox(
      width: rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: rowWidth - textFieldWidth, child: Text(text)),
          SizedBox(
            width: textFieldWidth,
            child: TextFormField(

              key: globalKey,
              readOnly: read,
              onTap: onTap,
              cursorColor: Colors.black,
              obscureText: isPassword,
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                contentPadding:
                homeController.isMobile.value
                    ? const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 10.0,
                )
                    : const EdgeInsets.fromLTRB(20, 15, 25, 15),
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
                errorStyle: const TextStyle(fontSize: 10.0, color: Colors.red),
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                  borderSide: BorderSide(width: 1, color: Colors.red),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                  borderSide: BorderSide(width: 1, color: Colors.red),
                ),
              ),
              onChanged: (value) => onChangedFunc?.call(value),
              validator: (value) {
                return onValidateFunc != null?onValidateFunc!(value!):null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneDialog {
  static Future<void> show(BuildContext context,TextEditingController numberController,String phoneCode,String number) async {
    String completePhoneNumber='';
    final GlobalKey<FormState> formKey = GlobalKey();
    await showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: formKey,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Enter Phone Number"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'LB',
                pickerDialogStyle: PickerDialogStyle(
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                onChanged: (phone) {
                  if(phone.isValidNumber()){
                    phoneCode=phone.countryCode;
                    number=phone.number;
                    completePhoneNumber=phone.completeNumber;
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed:() {
                  if(formKey.currentState!.validate()){
                  numberController.text=completePhoneNumber;
                  Navigator.pop(context);
                }},
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }
}


class StringWrapper {
  String value;
  StringWrapper(this.value);
}


