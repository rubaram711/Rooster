import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:rooster_app/Widgets/reusable_change_width_dropdown_body_package.dart';
import 'package:rooster_app/Widgets/reusable_change_width_dropdown_body_package_code.dart';
// import 'package:rooster_app/Widgets/reusable_popup_dropdown.dart';
import 'package:rooster_app/const/colors.dart';

class ReusableDropDownMenuWithoutSearch extends StatefulWidget {
  const ReusableDropDownMenuWithoutSearch(
      {super.key,
        required this.list,
        required this.text,
        required this.hint,
        required this.onSelected,
        required this.validationFunc,
        this.radius = 9,
        required this.rowWidth,
        required this.textFieldWidth});
  final List<String> list;
  final String text;
  final String hint;
  final Function onSelected;
  final Function validationFunc;
  final double radius;
  final double rowWidth;
  final double textFieldWidth;
  @override
  State<ReusableDropDownMenuWithoutSearch> createState() =>
      _ReusableDropDownMenuWithoutSearchState();
}

class _ReusableDropDownMenuWithoutSearchState
    extends State<ReusableDropDownMenuWithoutSearch> {
  String? dropDownValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: widget.rowWidth - widget.textFieldWidth,
              child: Text(widget.text)),
          SizedBox(
            width: widget.textFieldWidth,
            child: DropdownButtonFormField<String>(
              // autovalidateMode: AutovalidateMode.always,
              value: dropDownValue,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                  borderRadius:
                  BorderRadius.all(Radius.circular(widget.radius)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                  borderRadius:
                  BorderRadius.all(Radius.circular(widget.radius)),
                ),
                errorStyle: const TextStyle(
                  fontSize: 10.0,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(widget.radius)),
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                ),
              ),
              items: widget.list.map(
                    (String label) {
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(
                      label,
                    ),
                  );
                },
              ).toList(),
              hint: Text(widget.hint),
              onChanged: (String? value) {
                setState(() {
                  dropDownValue = value;
                });
                widget.onSelected(value);
              },
              validator: (value) {
                return widget.validationFunc(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}


class ReusableDropDownMenuWithSearch extends StatefulWidget {
  const ReusableDropDownMenuWithSearch(
      {super.key,
        required this.list,
        required this.text,
        required this.hint,
        required this.onSelected,
        required this.controller,
        required this.validationFunc,
        this.radius = 9,
        required this.rowWidth,
        required this.textFieldWidth, required this.clickableOptionText, required this.isThereClickableOption, required this.onTappedClickableOption});
  final List<String> list;
  final String text;
  final String hint;
  final Function onSelected;
  final TextEditingController controller;
  final Function validationFunc;
  final double radius;
  final double rowWidth;
  final double textFieldWidth;
  final String clickableOptionText;
  final bool isThereClickableOption;
  final Function onTappedClickableOption;
  @override
  State<ReusableDropDownMenuWithSearch> createState() =>
      _ReusableDropDownMenuWithSearchState();
}
class _ReusableDropDownMenuWithSearchState
    extends State<ReusableDropDownMenuWithSearch> {
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.list;
    widget.controller.addListener(_handleSearch);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleSearch);
    super.dispose();
  }

  void _handleSearch() {
    final filter = widget.controller.text.toLowerCase();
    setState(() {
      // Filter the list based on the user's input
      _filteredOptions = widget.list
          .where((option) => option.toLowerCase().contains(filter))
          .toList();

      // If no options match or always add the clickable option at the end
      if (widget.isThereClickableOption) {
        if (_filteredOptions.isEmpty || !_filteredOptions.contains(widget.clickableOptionText)) {
          _filteredOptions.add(widget.clickableOptionText);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: widget.rowWidth - widget.textFieldWidth,
              child: Text(widget.text)),
          FormField<String>(
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownMenu<String>(
                    width: widget.textFieldWidth,
                    enableSearch: true,
                    controller: widget.controller,
                    hintText: widget.hint,
                    inputDecorationTheme: InputDecorationTheme(
                      hintStyle: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: state.hasError ? Colors.red : Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                      ),
                    ),
                    menuHeight: 250,
                    dropdownMenuEntries: _filteredOptions.map<DropdownMenuEntry<String>>((String option) {
                      if (option == widget.clickableOptionText) {
                        return DropdownMenuEntry<String>(
                          value: option,
                          label: "",
                          labelWidget: GestureDetector(
                            onTap: () {
                              widget.onTappedClickableOption();
                            },
                            child: Text(
                              option,
                              style: TextStyle(color: Primary.primary, decoration: TextDecoration.underline),
                            ),
                          ),
                        );
                      } else {
                        return DropdownMenuEntry<String>(
                          value: option,
                          label: option,
                        );
                      }
                    }).toList(),
                    onSelected: (String? val) {
                      if (val != widget.clickableOptionText) {
                        state.didChange(val);
                        widget.onSelected(val);
                        state.validate();
                      }
                    },
                  ),
                  // DropdownMenu<String>(
                  //   width: widget.textFieldWidth,
                  //   // requestFocusOnTap: false,
                  //   enableSearch: true,
                  //   controller: widget.controller,
                  //   hintText: widget.hint,
                  //   inputDecorationTheme: InputDecorationTheme(
                  //     // filled: true,
                  //     hintStyle: const TextStyle(
                  //         color: Colors.grey, fontStyle: FontStyle.italic),
                  //     contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                  //     // outlineBorder: BorderSide(color: Colors.black,),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(
                  //           color: state.hasError
                  //               ? Colors.red
                  //               : Primary.primary.withAlpha((0.2 * 255).toInt()),
                  //           width: 1),
                  //       borderRadius:
                  //           BorderRadius.all(Radius.circular(widget.radius)),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(
                  //           color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                  //       borderRadius:
                  //           BorderRadius.all(Radius.circular(widget.radius)),
                  //     ),
                  //   ),
                  //   // menuStyle: ,
                  //   menuHeight: 250,
                  //   // dropdownMenuEntries: widget.list
                  //   //     .map<DropdownMenuEntry<String>>((String option) {
                  //   //   return DropdownMenuEntry<String>(
                  //   //     value: option,
                  //   //     label: option,
                  //   //   );
                  //   // }).toList(),
                  //   dropdownMenuEntries: _filteredOptions.map<DropdownMenuEntry<String>>(
                  //         (String option) {
                  //       if (option == "ClickableOption") {
                  //         return DropdownMenuEntry<String>(
                  //           value: "ClickableOption",
                  //           label: "",
                  //           labelWidget: GestureDetector(
                  //             onTap: () {
                  //               widget.onTappedClickableOption();
                  //             },
                  //             child: Text(
                  //               widget.clickableOptionText,
                  //               style: TextStyle(
                  //                   color: Colors.green,
                  //                   decoration: TextDecoration.underline),
                  //             ),
                  //           ),
                  //         );
                  //       }
                  //       return DropdownMenuEntry<String>(
                  //         value: option,
                  //         label: option,
                  //       );
                  //     },
                  //   ).toList(),
                  //   // dropdownMenuEntries: widget.isThereClickableOption
                  //   // ?[
                  //   //   ...widget.list.map<DropdownMenuEntry<String>>(
                  //   //     (String option) {
                  //   //       return DropdownMenuEntry<String>(
                  //   //         value: option,
                  //   //         label: option,
                  //   //       );
                  //   //     },
                  //   //   ),
                  //   //   DropdownMenuEntry<String>(
                  //   //     value: "ClickableOption",
                  //   //     label: "",
                  //   //     labelWidget: GestureDetector(
                  //   //       onTap: () {
                  //   //         widget.onTappedClickableOption();
                  //   //       },
                  //   //       child: Text(
                  //   //         widget.clickableOptionText,
                  //   //         style: TextStyle(color: Primary.primary,decoration:TextDecoration.underline),
                  //   //       ),
                  //   //     ),
                  //   //   ),
                  //   // ]: widget.list
                  //   //     .map<DropdownMenuEntry<String>>((String option) {
                  //   //   return DropdownMenuEntry<String>(
                  //   //     value: option,
                  //   //     label: option,
                  //   //   );
                  //   // }).toList(),
                  //   enableFilter: true,
                  //   onSelected: (String? val) {
                  //     if(val!='ClickableOption'){
                  //     state.didChange(val);
                  //     widget.onSelected(val);
                  //     state.validate();}
                  //   },
                  // ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 25),
                      child: Text(
                        state.errorText ?? '',
                        style: const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                ],
              );
            },
            validator: (value) {
              return widget.validationFunc(value);
            },
          ),
        ],
      ),
    );
  }
}


// change search way
class ReusableSearchDropDownMenu extends StatefulWidget {
  const ReusableSearchDropDownMenu(
      {super.key,
        required this.list,
        required this.text,
        required this.hint,
        required this.onSelected,
        required this.controller,
        required this.validationFunc,
        this.radius = 9,
        required this.rowWidth,
        required this.textFieldWidth});
  final List<String> list;
  final String text;
  final String hint;
  final Function onSelected;
  final TextEditingController controller;
  final Function validationFunc;
  final double radius;
  final double rowWidth;
  final double textFieldWidth;
  @override
  State<ReusableSearchDropDownMenu> createState() =>
      _ReusableSearchDropDownMenuState();
}
class _ReusableSearchDropDownMenuState
    extends State<ReusableSearchDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: widget.rowWidth - widget.textFieldWidth,
              child: Text(widget.text)),
          SizedBox(
            width: widget.textFieldWidth,
            child: DropdownSearch<String>(
              // mode: Mode.DIALOG,
              // showSearchBox: true,
              items: (filter, infiniteScrollProps) => widget.list
                  .where((item) =>
                  item.toLowerCase().contains(filter.toLowerCase()))
                  .toList(),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic),
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                      borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                      borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius)),
                    ),
                    errorStyle: const TextStyle(
                      fontSize: 10.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(widget.radius)),
                      borderSide: const BorderSide(width: 1, color: Colors.red),
                    )),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
                ),
                fit: FlexFit.loose,
                constraints: const BoxConstraints(),
                menuProps: MenuProps(
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
              ),
              validator: (value) {
                widget.validationFunc();
                return null;
              },
              onChanged: (value) {
                widget.onSelected(value);
              },
              // selectedItem: _selectedValue,
            ),
          ),
        ],
      ),
    );
  }
}



// //DropdownMenus where DropDown body(after open) greater than DropDownField and searchable and add new option with focus node and
// and search for any element in dropDown
class ReusableDropDownMenusWithSearch extends StatefulWidget {
  const ReusableDropDownMenusWithSearch({
    super.key,
    required this.list,
    required this.text,
    required this.hint,
    required this.onSelected,
    required this.controller,
    required this.validationFunc,
    this.radius = 9,
    required this.rowWidth,
    required this.textFieldWidth,
    required this.clickableOptionText,
    required this.isThereClickableOption,
    required this.onTappedClickableOption,
    required this.columnWidths,
    this.focusNode, // Added focusNode
    this.nextFocusNode, // Added nextFocusNode
  });

  final List<List<String>> list;
  final String text;
  final String hint;
  final Function(String?) onSelected;
  final TextEditingController controller;
  final Function validationFunc;
  final double radius;
  final double rowWidth;
  final double textFieldWidth;
  final String clickableOptionText;
  final bool isThereClickableOption;
  final Function onTappedClickableOption;
  final List<double> columnWidths;
  final FocusNode? focusNode; // Added focusNode
  final FocusNode? nextFocusNode; // Added nextFocusNode

  @override
  State<ReusableDropDownMenusWithSearch> createState() =>
      _ReusableDropDownMenusWithSearchState();
}

class _ReusableDropDownMenusWithSearchState
    extends State<ReusableDropDownMenusWithSearch> {
  List<List<String>> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.list;
    widget.controller.addListener(_handleSearch);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleSearch);
    super.dispose();
  }
  // search for first element in dropDown
  // void _handleSearch() {
  //   final filter = widget.controller.text.toLowerCase();
  //   setState(() {
  //     _filteredOptions = widget.list
  //         .where((option) => option[0].toLowerCase().contains(filter))
  //         .toList();
  //
  //     if (widget.isThereClickableOption) {
  //       if (_filteredOptions.isEmpty || !_filteredOptions.any((option) => option[0] == widget.clickableOptionText)) {
  //         _filteredOptions.add([widget.clickableOptionText]);
  //       }
  //     }
  //
  //
  //   });
  // }

  // search for any element in dropDown
  void _handleSearch() {
    final filter = widget.controller.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.list.where((option) {
        // Search in all elements of the option list
        return option.any((element) => element.toLowerCase().contains(filter));
      }).toList();

      if (widget.isThereClickableOption) {
        if (_filteredOptions.isEmpty ||
            !_filteredOptions.any(
                    (option) => option[0] == widget.clickableOptionText)) {
          _filteredOptions.add([widget.clickableOptionText]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: widget.rowWidth - widget.textFieldWidth,
            child: Text(widget.text),
          ),
          FormField<String>(
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownMenus<List<String>>(
                    width: widget.textFieldWidth,
                    enableSearch: true,
                    controller: widget.controller,
                    hintText: widget.hint,
                    textStyle: const TextStyle( fontSize:14),

                    inputDecorationTheme: InputDecorationTheme(

                      hintStyle: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: state.hasError ? Colors.red :
                        Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                      ),

                    ),
                    menuHeight: 250,

                    dropdownMenusEntries: _filteredOptions.map<DropdownMenusEntry<List<String>>>((List<String> option) {
                      if (option[0] == widget.clickableOptionText) {
                        return DropdownMenusEntry<List<String>>(
                          value: option,
                          label: "",
                          labelWidget: GestureDetector(
                            onTap: () {
                              widget.onTappedClickableOption();
                            },
                            child: Text(
                              option[0],
                              style: TextStyle(color: Primary.primary, decoration: TextDecoration.underline),
                            ),
                          ),
                        );
                      } else {
                        return DropdownMenusEntry<List<String>>(
                          value: option,
                          label: '',
                          labelWidget: Row(
                            children: List.generate(
                              widget.columnWidths.length,
                                  (index) => SizedBox(
                                width: widget.columnWidths[index],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(option[index],),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                    onSelected: (List<String>? val) {
                      if (val != null && val[0] != widget.clickableOptionText) {
                        state.didChange(val[0]);
                        widget.onSelected(val[0]);
                        state.validate();

                        if (widget.nextFocusNode != null) {
                          FocusScope.of(context).requestFocus(widget.nextFocusNode);
                        }
                      }
                    },
                    focusNode: widget.focusNode, // Attach focusNode
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 25),
                      child: Text(
                        state.errorText ?? '',
                        style: const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                ],
              );
            },
            validator: (value) {
              return widget.validationFunc(value);
            },
          ),
        ],
      ),
    );
  }
}


// //DropdownMenus where DropDown body(after open) greater than DropDownField and searchable and add new option
// used in quotation code
class ReusableDropDownMenusWithSearchCode extends StatefulWidget {
  const ReusableDropDownMenusWithSearchCode({
    super.key,
    required this.list,
    required this.text,
    required this.hint,
    required this.onSelected,
    required this.controller,
    required this.validationFunc,
    this.radius = 9,
    required this.rowWidth,
    required this.textFieldWidth,
    required this.clickableOptionText,
    required this.isThereClickableOption,
    required this.onTappedClickableOption,
    required this.columnWidths, // Added columnWidths
  });

  final List<List<String>> list; // Change to List<List<String>>
  final String text;
  final String hint;
  final Function(String?) onSelected; // Change to Function(String?)
  final TextEditingController controller;
  final Function validationFunc;
  final double radius;
  final double rowWidth;
  final double textFieldWidth;
  final String clickableOptionText;
  final bool isThereClickableOption;
  final Function onTappedClickableOption;
  final List<double> columnWidths; // Added columnWidths

  @override
  State<ReusableDropDownMenusWithSearchCode> createState() =>
      _ReusableDropDownMenusWithSearchCodeState();
}

class _ReusableDropDownMenusWithSearchCodeState
    extends State<ReusableDropDownMenusWithSearchCode> {
  List<List<String>> _filteredOptions = []; // Change to List<List<String>>

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.list;
    widget.controller.addListener(_handleSearch);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleSearch);
    super.dispose();
  }

  void _handleSearch() {
    final filter = widget.controller.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.list.where((option) {
        // Search in all elements of the option list
        return option.any((element) => element.toLowerCase().contains(filter));
      }).toList();

      if (widget.isThereClickableOption) {
        if (_filteredOptions.isEmpty ||
            !_filteredOptions.any(
                    (option) => option[0] == widget.clickableOptionText)) {
          _filteredOptions.add([widget.clickableOptionText]);
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: widget.rowWidth - widget.textFieldWidth,
            child: Text(widget.text),
          ),
          FormField<String>(
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownMenusCodeCode<List<String>>( // Change type to List<String>
                    width: widget.textFieldWidth,
                    enableSearch: true,
                    controller: widget.controller,
                    hintText: widget.hint,
                    inputDecorationTheme: InputDecorationTheme(
                      hintStyle: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: state.hasError ? Colors.red : Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                      ),
                    ),
                    menuHeight: 250,

                    dropdownMenusEntries: _filteredOptions.map<DropdownMenusCodeCodeEntry<List<String>>>((List<String> option) {
                      if (option[0] == widget.clickableOptionText) {
                        return DropdownMenusCodeCodeEntry<List<String>>(
                          value: option,
                          label: "",
                          labelWidget: GestureDetector(
                            onTap: () {
                              widget.onTappedClickableOption();
                            },
                            child: Text(
                              option[0],
                              style: TextStyle(color: Primary.primary, decoration: TextDecoration.underline),
                            ),
                          ),
                        );
                      } else {
                        return DropdownMenusCodeCodeEntry<List<String>>(
                          value: option,
                          label: '',
                          labelWidget: Row(
                            children: List.generate(
                              widget.columnWidths.length,
                                  (index) => SizedBox(
                                width: widget.columnWidths[index],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(option[index]),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                    onSelected: (List<String>? val) {
                      if (val != null && val[0] != widget.clickableOptionText) {
                        state.didChange(val[0]); // Pass the first element to FormField
                        widget.onSelected(val[0]); // Pass the first element to onSelected
                        state.validate();
                      }
                    },
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 25),
                      child: Text(
                        state.errorText ?? '',
                        style: const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                ],
              );
            },
            validator: (value) {
              return widget.validationFunc(value);
            },
          ),
        ],
      ),
    );
  }
}





