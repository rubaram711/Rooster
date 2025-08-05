// import 'dart:js_interop';

import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_picker_dropdown.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/const/colors.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../const/countries_list.dart';
// import 'package:country_picker/country_picker.dart';

class ReusableTextField extends StatefulWidget {
  const ReusableTextField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.hint,
    required this.isPasswordField,
    this.isEnable = true,
    required this.textEditingController,
  });
  final Function onChangedFunc;
  final Function validationFunc;
  final String hint;
  final bool isPasswordField;
  final bool isEnable;
  final TextEditingController textEditingController;
  @override
  State<ReusableTextField> createState() => _ReusableTextFieldState();
}

class _ReusableTextFieldState extends State<ReusableTextField> {
  bool showPassword = false;
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      enabled: widget.isEnable,
      cursorColor: Colors.black,
      obscureText: widget.isPasswordField ? !showPassword : false,
      decoration: InputDecoration(
        hintText: widget.hint,
        // labelStyle: TextStyle(
        //   color: kBasicColor
        // ),
        // filled: true,
        // fillColor: Colors.white,
        suffixIcon:
        widget.isPasswordField
            ? IconButton(
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
            size: 23,
          ),
        )
            : null,
        contentPadding:
        homeController.isMobile.value
            ? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0)
            : const EdgeInsets.fromLTRB(10, 0, 25, 5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        errorStyle: const TextStyle(fontSize: 10.0),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      validator: (value) {
        return widget.validationFunc(value);
      },
      onChanged: (value) => widget.onChangedFunc(value),
    );
  }
}

class ReusableNumberField extends StatefulWidget {
  const ReusableNumberField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.hint,
    required this.isPasswordField,
    this.isEnable = true,
    this.isCentered = false,
    required this.textEditingController,
  });
  final Function onChangedFunc;
  final Function validationFunc;
  final String hint;
  final bool isPasswordField;
  final bool isEnable;
  final bool isCentered;
  final TextEditingController textEditingController;
  @override
  State<ReusableNumberField> createState() => _ReusableNumberFieldState();
}

class _ReusableNumberFieldState extends State<ReusableNumberField> {
  bool showPassword = false;
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      enabled: widget.isEnable,
      textAlign: widget.isCentered ? TextAlign.center : TextAlign.left,
      cursorColor: Colors.black,
      obscureText: widget.isPasswordField ? !showPassword : false,
      decoration: InputDecoration(
        hintText: widget.hint,
        // labelStyle: TextStyle(
        //   color: kBasicColor
        // ),
        // filled: true,
        // fillColor: Colors.white,
        suffixIcon:
        widget.isPasswordField
            ? IconButton(
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
            size: 23,
          ),
        )
            : null,
        contentPadding:
        homeController.isMobile.value
            ? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0)
            : const EdgeInsets.fromLTRB(10, 0, 25, 5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        errorStyle: const TextStyle(fontSize: 10.0),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      validator: (value) {
        return widget.validationFunc(value);
      },
      onChanged: (value) => widget.onChangedFunc(value),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: true,
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
        // NumberFormatter(),
        // WhitelistingTextInputFormatter.digitsOnly
      ],
    );
  }
}

class ReusableSearchTextField extends StatefulWidget {
  const ReusableSearchTextField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.hint,
    required this.textEditingController,
  });
  final Function onChangedFunc;
  final Function validationFunc;
  final String hint;
  final TextEditingController textEditingController;
  @override
  State<ReusableSearchTextField> createState() =>
      _ReusableSearchTextFieldState();
}

class _ReusableSearchTextFieldState extends State<ReusableSearchTextField> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
        contentPadding:
        homeController.isMobile.value
            ? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0)
            : const EdgeInsets.fromLTRB(20, 0, 25, 5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Primary.primary, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Primary.primary, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(9)),
        ),
        errorStyle: const TextStyle(fontSize: 10.0),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9)),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      // validator: (value) {
      //   return widget.validationFunc(value);
      // },
      onChanged: (value) => widget.onChangedFunc(value),
    );
  }
}

class DialogTextField extends StatelessWidget {
  const DialogTextField({
    super.key,

    this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.rowWidth,
    required this.textFieldWidth,
    required this.textEditingController,
    this.hint = '',
    this.isPassword = false,
    this.globalKey,
    this.read = false,
  });
  final Function(String)? onChangedFunc;
  final Function validationFunc;
  final String text;
  final String hint;
  final double rowWidth;
  final double textFieldWidth;
  final TextEditingController textEditingController;
  final bool isPassword;
  final GlobalKey? globalKey;
  final bool read;

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
              cursorColor: Colors.black,
              obscureText: isPassword,
              controller: textEditingController,
              decoration: InputDecoration(
                // isDense: true,
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
              validator: (value) {
                return validationFunc(value);
              },
              onChanged: (value) => onChangedFunc!(value),
            ),
          ),
        ],
      ),
    );
  }
}

class DialogNumericTextField extends StatelessWidget {
  const DialogNumericTextField({
    super.key,
    // required this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.rowWidth,
    required this.textFieldWidth,

    required this.textEditingController,
    this.hint = '',
    this.read = false,
  });
  // final Function onChangedFunc;
  final Function validationFunc;
  final String text;
  final String hint;
  final double rowWidth;
  final double textFieldWidth;
  final bool read;
  final TextEditingController textEditingController;
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
              readOnly: read,
              controller: textEditingController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: hint,
                // labelStyle: TextStyle(
                //   color: kBasicColor
                // ),
                // filled: true,
                // fillColor: Colors.white,
                contentPadding:
                homeController.isMobile.value
                    ? const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 10.0,
                )
                    : const EdgeInsets.fromLTRB(10, 0, 25, 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                errorStyle: const TextStyle(fontSize: 10.0),
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(width: 1, color: Colors.red),
                ),
              ),
              validator: (value) {
                return validationFunc(value);
              },
              // onChanged: (value) =>  onChangedFunc(value),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                // NumberFormatter(),
                // WhitelistingTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DialogDateTextField extends StatefulWidget {
  const DialogDateTextField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.textFieldWidth,
    required this.textEditingController,
    required this.onDateSelected,
    this.isDottedDate = true,
  });
  final Function onChangedFunc;
  final Function onDateSelected;
  final Function validationFunc;
  final String text;
  final double textFieldWidth;
  final TextEditingController textEditingController;
  final bool isDottedDate;
  @override
  State<DialogDateTextField> createState() => _DialogDateTextFieldState();
}

class _DialogDateTextFieldState extends State<DialogDateTextField> {
  HomeController homeController = Get.find();
  DateTime selectedDate = DateTime.now();
  bool isDateSelected = false;
  String formattedDate = '';
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isDateSelected = true;
        formattedDate =
        widget.isDottedDate
            ? DateFormat('yyyy-MM-dd').format(selectedDate)
            : DateFormat('yyyy-MM-dd').format(selectedDate);
        widget.onDateSelected(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.textFieldWidth,
      child: TextFormField(
        cursorColor: Colors.black,
        controller: widget.textEditingController,
        decoration: InputDecoration(
          hintText:
          isDateSelected
              ? formattedDate
              : widget.textEditingController.text.isNotEmpty
              ? widget.textEditingController.text
              : widget.text,
          suffixIcon: Icon(Icons.calendar_month, color: Primary.primary),
          contentPadding:
          homeController.isMobile.value
              ? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0)
              : const EdgeInsets.fromLTRB(20, 0, 25, 5),
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
        onTap: () {
          _selectDate(context);
        },
        onChanged: (value) => widget.onChangedFunc(value),
      ),
    );
  }
}

class DialogTimeTextField extends StatefulWidget {
  const DialogTimeTextField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.textFieldWidth,
    required this.textEditingController,
    required this.onTimeSelected,
  });
  final Function onChangedFunc;
  final Function onTimeSelected;
  final Function validationFunc;
  final String text;
  final double textFieldWidth;
  final TextEditingController textEditingController;
  @override
  State<DialogTimeTextField> createState() => _DialogTimeTextFieldState();
}

class _DialogTimeTextFieldState extends State<DialogTimeTextField> {
  HomeController homeController = Get.find();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isTimeSelected = false;
  String formattedTime = '';
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (timeOfDay != null) {
      setState(() {
        selectedTime = timeOfDay;
        isTimeSelected = true;
        formattedTime = '${selectedTime.hour}:${selectedTime.minute}';
        widget.onTimeSelected(formattedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.textFieldWidth,
      child: TextFormField(
        cursorColor: Colors.black,
        controller: widget.textEditingController,
        decoration: InputDecoration(
          hintText: isTimeSelected ? formattedTime : widget.text,
          suffixIcon: Icon(
            Icons.access_time_filled_outlined,
            color: Primary.primary,
          ),
          contentPadding:
          homeController.isMobile.value
              ? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0)
              : const EdgeInsets.fromLTRB(20, 0, 25, 5),
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
        onTap: () async {
          await _selectTime(context);
        },
        onChanged: (value) => widget.onChangedFunc(value),
      ),
    );
  }
}

// class NumberFormatter extends TextInputFormatter {
//   final _numberFormat = NumberFormat.decimalPattern();
//
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     // Remove any existing formatting
//     final text = newValue.text.replaceAll(',', '');
//
//     if (text.isEmpty) {
//       return newValue.copyWith(text: '');
//     }
//
//     // Format the input with commas
//     final formattedNumber = _numberFormat.format(int.parse(text));
//
//     return TextEditingValue(
//       text: formattedNumber,
//       selection: TextSelection.collapsed(offset: formattedNumber.length),
//     );
//   }
// }

class ReusableInputNumberField extends StatefulWidget {
  const ReusableInputNumberField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.textFieldWidth,
    required this.rowWidth,
    required this.controller,
  });
  final Function onChangedFunc;
  final Function validationFunc;
  final String text;
  final double textFieldWidth;
  final double rowWidth;
  final TextEditingController controller;
  @override
  State<ReusableInputNumberField> createState() =>
      _ReusableInputNumberFieldState();
}

class _ReusableInputNumberFieldState extends State<ReusableInputNumberField> {
  HomeController homeController = Get.find();

  @override
  void initState() {
    // widget.controller.text == '';
    // ? widget.controller.text = "0"
    // : widget.controller.text = widget.controller.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.text),
          Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              SizedBox(
                width: widget.textFieldWidth,
                child: TextFormField(
                  // textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding:
                    homeController.isMobile.value
                        ? const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 10.0,
                    )
                        : const EdgeInsets.fromLTRB(20, 0, 25, 10),
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
                  controller: widget.controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    // FilteringTextInputFormatter.digitsOnly,
                    // NumberFormatter(),
                    // WhitelistingTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              SizedBox(
                height: 38.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: const Icon(Icons.arrow_drop_up, size: 18.0),
                      onTap: () {
                        if (widget.controller.text != '') {
                          Decimal currentValue = Decimal.parse(
                            widget.controller.text,
                          );
                          setState(() {
                            currentValue = currentValue + Decimal.parse('1');
                            widget.controller.text =
                                (currentValue).toString(); // incrementing value
                          });
                        }
                      },
                    ),
                    InkWell(
                      child: const Icon(Icons.arrow_drop_down, size: 18.0),
                      onTap: () {
                        if (widget.controller.text != '') {
                          Decimal currentValue = Decimal.parse(
                            widget.controller.text,
                          );
                          setState(() {
                            currentValue = currentValue - Decimal.parse('1');
                            widget.controller.text =
                                (currentValue > Decimal.parse('0')
                                    ? currentValue
                                    : 0)
                                    .toString(); // decrementing value
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PhoneTextField extends StatefulWidget {
  const PhoneTextField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.rowWidth,
    required this.textFieldWidth,
    required this.textEditingController,
    this.hint = '',
    required this.onCodeSelected,
    this.initialValue = '',
    this.globalKey,
  });
  final Function onChangedFunc;
  final Function validationFunc;
  final Function onCodeSelected;
  final String text;
  final String initialValue;
  final String hint;
  final double rowWidth;
  final double textFieldWidth;
  final TextEditingController textEditingController;
  final GlobalKey? globalKey;

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.text),
          SizedBox(
            width: widget.textFieldWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                      width: 1,
                    ),
                  ),
                  width: 160,
                  padding:
                  homeController.isMobile.value
                      ? const EdgeInsets.symmetric(
                    vertical: 11.5,
                    horizontal: 2.0,
                  )
                      : EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                  child: CountryPickerDropdown(
                    initialValue:
                    widget.initialValue == ''
                        ? 'lb'
                        : separatePhoneAndDialCode(widget.initialValue),
                    itemBuilder: _buildDropdownItem,
                    onValuePicked: (Country? country) {
                      // print("+${country!.phoneCode}");
                      setState(() {
                        widget.onCodeSelected("+${country!.phoneCode}");
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: widget.textFieldWidth - 162,
                  child: TextFormField(
                    key: widget.globalKey,
                    cursorColor: Colors.black,
                    controller: widget.textEditingController,
                    decoration: InputDecoration(
                      hintText: widget.hint,
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
                          : const EdgeInsets.fromLTRB(10, 0, 10, 5),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                      errorStyle: const TextStyle(fontSize: 10.0),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      // WhitelistingTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      return widget.validationFunc(value);
                    },
                    onChanged: (value) => widget.onChangedFunc(value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(Country country) => SizedBox(
    width: 130,
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 30,
          child: CountryPickerUtils.getDefaultFlagImage(country),
        ),
        // SizedBox(
        //   width: 3.0,
        // ),
        // Text("+${country.phoneCode}(${country.isoCode})"),
        SizedBox(
          width: 100,
          child: Text(
            "+${country.phoneCode}  ${country.name}",
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );

// _buildCountryPickerDropdown(bool filtered) => Row(
//   children: <Widget>[
//     CountryPickerDropdown(
//       initialValue: 'AR',
//       itemBuilder: _buildDropdownItem,
//       itemFilter: filtered
//           ? (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode)
//           : null,
//       onValuePicked: (Country? country) {
//         print("${country?.name}");
//       },
//     ),
//     const SizedBox(
//       width: 8.0,
//     ),
//     const Expanded(
//       child: TextField(
//         decoration: InputDecoration(labelText: "Phone"),
//       ),
//     )
//   ],
// );
}

// class ReusableDecimalTextField extends StatefulWidget {
//   const ReusableDecimalTextField({super.key});
//
//   @override
//   State<ReusableDecimalTextField> createState() => _ReusableDecimalTextFieldState();
// }
//
// class _ReusableDecimalTextFieldState extends State<ReusableDecimalTextField> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
