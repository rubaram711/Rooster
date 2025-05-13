import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../Controllers/products_controller.dart';

class ShelvingTabContent extends StatefulWidget {
  const ShelvingTabContent({super.key, required this.isDesktop});
  final bool isDesktop;
  @override
  State<ShelvingTabContent> createState() => _ShelvingTabContentState();
}

class _ShelvingTabContentState extends State<ShelvingTabContent> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (cont) {
      return SizedBox(
        height: widget.isDesktop?MediaQuery.of(context).size.height * 0.7:MediaQuery.of(context).size.height * 0.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // const Spacer(),
            // ReusableBTNsRow(
            //   onBackClicked: () {
            //     cont.setSelectedTabIndex(5);
            //   },
            //   onDiscardClicked: () {
            //   },
            //   onNextClicked: () {
            //     cont.setSelectedTabIndex(7);
            //   },
            //   onSaveClicked: () {},
            // )
          ],
        ),
      );
    });
  }
}
