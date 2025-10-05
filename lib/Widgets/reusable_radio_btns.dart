import 'package:flutter/material.dart';

class ReusableRadioBtns extends StatefulWidget {
  const ReusableRadioBtns({
    super.key,
    required this.title1,
    required this.title2,
    required this.func, required this.width1, required this.width2, required this.groupVal, required this.isRow,
  });
  final String title1;
  final String title2;
  final Function func;
  final double width1;
  final double width2;
  final int groupVal;
  final bool isRow;
  @override
  State<ReusableRadioBtns> createState() => _ReusableRadioBtnsState();
}

class _ReusableRadioBtnsState extends State<ReusableRadioBtns> {
  late int groupVal ;
  List<Widget> children=<Widget>[];
  @override
  void initState() {
    groupVal=widget.groupVal;
    children=<Widget>[
      SizedBox(
        width: widget.width1,
        child: ListTile(
          title: Text(widget.title1),
          leading: Radio<int>(value: 1),
        ),
      ),
      SizedBox(
        width: widget.width2,
        child: ListTile(
          title: Text(widget.title2),
          leading: Radio<int>(value: 2),
        ),
      ),
    ];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: groupVal,
      onChanged: (int? value) {
        setState(() {
          groupVal = value!;
        });
        widget.func(value);
      },
      child: widget.isRow
          ?  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      )
      :Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
      ),
    );
  }
}


class ReusableFlexibleRadioBtns extends StatefulWidget {
  const ReusableFlexibleRadioBtns({
    super.key,

    required this.func, required this.groupVal, required this.isRow, required this.titles, required this.widths, required this.length,
  });
  final List<String> titles;
  final Function func;
  final List<double> widths;
  final int groupVal;
  final int length;
  final bool isRow;
  @override
  State<ReusableFlexibleRadioBtns> createState() => _ReusableFlexibleRadioBtnsState();
}

class _ReusableFlexibleRadioBtnsState extends State<ReusableFlexibleRadioBtns> {
  late int groupVal ;
  List<Widget> children=<Widget>[];
  addChildren(){
    for(int i=0;i<widget.length;i++){
      children.add( SizedBox(
        width: widget.widths[i],
        child: ListTile(
          title: Text(widget.titles[i]),
          leading: Radio<int>(value: i+1),
        ),
      ));
    }
  }
  @override
  void initState() {
    groupVal=widget.groupVal;
    addChildren();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return RadioGroup<int>(
      groupValue: groupVal,
      onChanged: (int? value) {
        setState(() {
          groupVal = value!;
        });
        widget.func(value);
      },
      child: widget.isRow
          ?  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      )
      :Column(
          mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
      ),
    );
  }
}
