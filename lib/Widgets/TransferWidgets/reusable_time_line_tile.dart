import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../const/colors.dart';



class ReusableTimeLineTile extends StatelessWidget {
  const ReusableTimeLineTile(
      {super.key,
        required this.isFirst,
        required this.isLast,
        required this.isPast,
        required this.text,
        required this.id,
        required this.progressVar,
        this.isDesktop = true});
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final bool isDesktop;
  final String text;
  final int id;
  final int progressVar;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: isDesktop
            ? MediaQuery.of(context).size.width * 0.13
            : MediaQuery.of(context).size.width * 0.3,
        height: 50,
        child: TimelineTile(
          axis: TimelineAxis.horizontal,
          isFirst: isFirst,
          isLast: isLast,
          beforeLineStyle: LineStyle(
              color: id <= progressVar ? Primary.primary : Others.btnBg),
          indicatorStyle: IndicatorStyle(
            // width: 40,
              color: id <= progressVar ? Primary.primary : Others.btnBg,
              iconStyle: IconStyle(
                  iconData: Icons.circle,
                  fontSize: 30,
                  color: id <= progressVar ? Primary.primary : Others.btnBg)),
          endChild: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(text),
          ),
        ));
  }
}