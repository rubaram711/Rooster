import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import '../Backend/Quotations/get_references.dart';
import '../const/colors.dart';

class ReusableReferenceTextField extends StatefulWidget {
  const ReusableReferenceTextField({super.key,
    // this.onChangedFunc,
    required this.rowWidth, required this.textFieldWidth, required this.textEditingController, required this.type});
  // final Function(String)? onChangedFunc;
  final double rowWidth;
  final double textFieldWidth;
  final String type;
  final TextEditingController textEditingController;




  @override
  State<ReusableReferenceTextField> createState() => _ReusableReferenceTextFieldState();
}

class _ReusableReferenceTextFieldState extends State<ReusableReferenceTextField> {
  List<String> allReferences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  Future<void> _fetchReferences() async {
    try {
      final response = await getAllReferences('');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        allReferences = jsonResponse['data'][widget.type]
            .where((item) => item['reference'] != null)
            .map<String>((item) => item['reference'] as String)
            .toList();

      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      //print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
HomeController homeController=Get.find();
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: widget.rowWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${'ref'.tr}:'),
            SizedBox(
              width: widget.textFieldWidth,
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return allReferences.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  widget.textEditingController.text = selection;
                },
                fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  if( widget.textEditingController.text.isNotEmpty ){
                    fieldTextEditingController.text= widget.textEditingController.text;
                  }
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: focusNode,
                    onSubmitted: (String value) {
                      // print('Submitted value: $value');
                    },
                    decoration: InputDecoration(
                      // isDense: true,
                      hintText: 'manual_reference'.tr,
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
                    onChanged: (String? val){
                      widget.textEditingController.text=val!;
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                  // هذا الجزء مسؤول عن شكل القائمة المنبثقة
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints:  BoxConstraints(maxHeight: 200,maxWidth: widget.textFieldWidth),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
