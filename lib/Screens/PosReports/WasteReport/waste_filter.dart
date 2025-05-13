import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/pos_controller.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Controllers/waste_reports_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';


class WasteDetailsFilter extends StatefulWidget {
  const WasteDetailsFilter({super.key});

  @override
  State<WasteDetailsFilter> createState() => _WasteDetailsFilterState();
}

class _WasteDetailsFilterState extends State<WasteDetailsFilter> {
  final HomeController homeController = Get.find();
  final WasteReportsController sessionController = Get.find();
  final PosController posController = Get.find();


  @override
  void initState() {
    sessionController.getSessionsFromBack();
    posController.getPossFromBack();
    super.initState();
    sessionController.selectedPosId = '';
    sessionController.dateController.clear();
    sessionController.sessionNumberController.clear();
    sessionController.posTerminalController.clear();
  }
  int selectedFilterOption = 1;

  @override
  Widget build(BuildContext context) {
    var radioBtnWidth = MediaQuery.of(context).size.width * 0.15;
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
      child: GetBuilder<WasteReportsController>(
        builder: (wasteCont) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(text: 'daily_qty_report'.tr),
              // gapH32,
              // const AddPhotoCircle(),
              gapH32,
              Row(
                children: [
                  SizedBox(
                    width: radioBtnWidth,
                    child: ListTile(
                      title: Text(
                        'date'.tr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      leading: Radio(
                        value: 1,
                        groupValue: selectedFilterOption,
                        onChanged: (value) {
                          setState(() {
                            selectedFilterOption = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: menuWidth,
                    child: ListTile(
                      title: Text(
                        'session_number'.tr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      leading: Radio(
                        value: 2,
                        groupValue: selectedFilterOption,
                        onChanged: (value) {
                          setState(() {
                            selectedFilterOption = value!;
                          });
                        },
                      ),
                    ),
                  ),

                ],
              ),
              gapH16,
              selectedFilterOption == 1?
              SizedBox(
                width: sizeBoxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('date'.tr),
                    DialogDateTextField(
                      textEditingController:
                      wasteCont.dateController,
                      text: '',
                      textFieldWidth: menuWidth,
                      validationFunc: (val) {},
                      onChangedFunc: (val) {
                        wasteCont.dateController.text = val;
                      },
                      onDateSelected: (value) {
                        wasteCont.dateController.text = value;
                      },
                    ),
                  ],
                ),
              ):
              SizedBox(
                width: sizeBoxWidth,
                child:
                wasteCont.isSessionsFetched
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('session_number'.tr),
                    DropdownMenu<String>(
                      width: menuWidth,
                      // requestFocusOnTap: false,
                      enableSearch: true,
                      controller:
                      wasteCont.sessionNumberController,
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
                      wasteCont.sessionsNumbers
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
                        wasteCont.sessionNumberController.text =
                        val!;
                        var index=wasteCont.sessionsNumbers.indexOf(val);
                        wasteCont.setSelectedSessionId(wasteCont.sessionsIds[index]);
                      },
                    ),
                  ],
                )
                    : loading(),
              ),
              gapH16,
              SizedBox(
                width: sizeBoxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('pos'.tr),
                    GetBuilder<PosController>(
                      builder: (cont) {
                        return cont.isPossFetched
                            ? DropdownMenu<String>(
                          width: menuWidth,
                          // requestFocusOnTap: false,
                          enableSearch: true,
                          controller: wasteCont.posTerminalController,
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
                          cont.possNamesList
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
                              var index = cont.possNamesList.indexOf(
                                val!,
                              );
                              wasteCont.setSelectedPos(
                                cont.possIdsList[index],
                                val,
                              );
                            });
                          },
                        )
                            : loading();
                      },
                    ),
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
                        wasteCont.selectedPosId = '';
                        wasteCont.selectedPosName = '';
                        wasteCont.posTerminalController.clear();
                        wasteCont.dateController.clear();
                        wasteCont.sessionNumberController.clear();
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
                      // if (
                      //     sessionCont.dateController.text.isEmpty) {
                      //   CommonWidgets.snackBar(
                      //     'error',
                      //     'Date is required',
                      //   );
                      // } else
                      //   if (
                      //     sessionCont.sessionNumberController.text.isEmpty) {
                      //   CommonWidgets.snackBar(
                      //     'error',
                      //     'Session Number is required',
                      //   );
                      // }
                      //   else if (sessionCont.posController.text.isEmpty) {
                      //   CommonWidgets.snackBar('error', 'Currency is required');
                      // }
                      // else {
                        await wasteCont.getWasteDetailsFromBack();
                        if (wasteCont.errorMessage == '') {
                          homeController.selectedTab.value =
                          'waste_details_after_filter';
                        } else {
                          CommonWidgets.snackBar(
                            'error',
                            wasteCont.errorMessage,
                          );
                        }
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
