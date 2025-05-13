import 'package:flutter/material.dart';

import '../const/colors.dart';

class DialogDropMenu extends StatefulWidget {
  const DialogDropMenu(
      {super.key,
        required this.optionsList,
        required this.rowWidth,
        required this.textFieldWidth,
        required this.text,
        required this.onSelected,
        required this.hint,
        this.controller,
        });
  final List<String> optionsList;
  final double rowWidth;
  final double textFieldWidth;
  final String text;
  final String hint;
  final Function onSelected;
  final TextEditingController? controller;
  @override
  State<DialogDropMenu> createState() => _DialogDropMenuState();
}

class _DialogDropMenuState extends State<DialogDropMenu> {
  // final TextEditingController controller = TextEditingController();
  // String? selectedItem;
  @override
  void initState() {
    // selectedItem = widget.optionsList[0];
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
          DropdownMenu<String>(
            controller: widget.controller,
            width: widget.textFieldWidth,
            requestFocusOnTap: false,
            hintText: widget.hint,
            inputDecorationTheme: InputDecorationTheme(
              // filled: true,
              hintStyle: TextStyle(
                color: Colors.grey[300]
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
              // outlineBorder: BorderSide(color: Colors.black,),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(9)),
              ),
            ),
            dropdownMenuEntries: widget.optionsList
                .map<DropdownMenuEntry<String>>((String option) {
              return DropdownMenuEntry<String>(
                value: option,
                label: option
                // enabled: option.label != 'Grey',
                // style: MenuItemButton.styleFrom(
                // foregroundColor: color.color,
                // ),
              );
            }).toList(),
            onSelected: (String? val) {
              widget.onSelected(val);
              // setState(() {
              //   selectedItem = val!;
              // });
            },
          ),
        ],
      ),
    );
  }
}