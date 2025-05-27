import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/pos_controller.dart';
import '../../../Controllers/cash_trays_controller.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import 'cash_tray_report.dart';


class CashTrayFilter extends StatefulWidget {
  const CashTrayFilter({super.key});

  @override
  State<CashTrayFilter> createState() => _CashTrayFilterState();
}

class _CashTrayFilterState extends State<CashTrayFilter> {
  final HomeController homeController = Get.find();

  final PosController posController = Get.find();
  CashTraysController cashTraysController = Get.find();
  TextEditingController selectedCashTrayNumberController =
  TextEditingController();

  @override
  void initState() {
    cashTraysController.getCashTraysFromBack();

    posController.getPossFromBack();
    super.initState();
    cashTraysController.selectedCashTrayController.clear();
  }
  int selectedFilterOption = 1;

  @override
  Widget build(BuildContext context) {
    var sizeBoxWidth = homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.8:MediaQuery.of(context).size.width * 0.35;
    var menuWidth =homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5: MediaQuery.of(context).size.width * 0.2;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
        homeController.isMobile.value
            ? MediaQuery.of(context).size.width * 0.05
            : MediaQuery.of(context).size.width * 0.02,
      ),
      height:
      homeController.isMobile.value
          ? MediaQuery.of(context).size.height * 0.75
          : MediaQuery.of(context).size.height * 0.85,
      child: GetBuilder<CashTraysController>(
        builder: (cashCont) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(text: 'cash_tray_report'.tr),
              // gapH32,
              // const AddPhotoCircle(),
              gapH32,
              SizedBox(
                width: sizeBoxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('cash_tray_number'.tr),
                    cashCont.isCashTraysFetched
                            ? DropdownMenu<String>(
                          width: menuWidth,
                          // requestFocusOnTap: false,
                          enableSearch: true,
                          controller: cashCont.selectedCashTrayController,
                          hintText: '',
                          inputDecorationTheme: InputDecorationTheme(
                            // filled: true,
                            hintStyle: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              25,
                              5,
                            ),
                            // outlineBorder: BorderSide(color: Colors.black,),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Primary.primary.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(9),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Primary.primary.withAlpha(
                                  (0.4 * 255).toInt(),
                                ),
                                width: 2,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(9),
                              ),
                            ),
                          ),
                          // menuStyle: ,
                          menuHeight: 250,
                          dropdownMenuEntries:
                          cashCont.cashTraysNumbersList
                              .map<DropdownMenuEntry<String>>((
                              String option,
                              ) {
                            return DropdownMenuEntry<String>(
                              value: option,
                              label: option,
                            );
                          })
                              .toList(),
                          enableFilter: true,
                          onSelected: (String? val) {
                            setState(() {
                              var index = cashCont.cashTraysNumbersList.indexOf(
                                val!,
                              );
                              cashCont.setSelectedCashTrayId(
                                cashCont.cashTraysIdsList[index],
                              );
                            });
                          },
                        )
                            : loading(),

                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        cashCont.selectedCashTrayController.clear();
                        cashCont.selectedCashTrayId = '';
                      });
                    },
                    child: Text(
                      'discard'.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Primary.primary,
                      ),
                    ),
                  ),
                  gapW24,
                  ReusableButtonWithColor(
                    btnText: 'save'.tr,
                    onTapFunction: () async {
                      if(cashCont.selectedCashTrayId==''){
                        CommonWidgets.snackBar(
                          'error',
                          'Select Cash Tray Number First',
                        );
                      }else{
                      var res=await cashCont.getCashTrayReportFromBack();
                      if (res['success'] == true) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                              return const CashTraysReport();
                            }));
                      } else {
                        CommonWidgets.snackBar(
                          'error',
                          res['message'],
                        );
                      }}
                    },
                    // },
                    width: 100,
                    height: 35,
                  ),
                ],
              ),
              gapH40,
            ],
          );
        },
      ),
    );
  }
}
