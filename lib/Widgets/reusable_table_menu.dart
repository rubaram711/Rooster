import 'package:flutter/material.dart';

import '../const/colors.dart';


class ReusableStatusDropdown extends StatefulWidget {
  final List<String> options;
  final String value;
  final void Function(String) onSelected;
  final double? width;

  const ReusableStatusDropdown({
    super.key,
    required this.options,
    required this.onSelected,
    this.width, required this.value,
  });

  @override
  State<ReusableStatusDropdown> createState() => _ReusableStatusDropdownState();
}

class _ReusableStatusDropdownState extends State<ReusableStatusDropdown> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.options.isNotEmpty) {
      _selected = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdown = DropdownButtonFormField<String>(
      value: _selected,
      items: widget.options
          .map((s) => DropdownMenuItem<String>(
        value: s,
        child: Text(s),
      ))
          .toList(),
      onChanged: (newValue) {
        if (newValue == null) return;
        setState(() {
          _selected = newValue;
        });
        widget.onSelected(newValue);
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Primary.primary, width: 1.2),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      style: const TextStyle(fontSize: 12),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: dropdown);
    }
    return dropdown;
  }
}