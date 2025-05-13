import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/session_controller.dart';
import '../../../Controllers/exchange_rates_controller.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

class SessionDetailsFilter extends StatefulWidget {
  const SessionDetailsFilter({super.key});

  @override
  State<SessionDetailsFilter> createState() => _SessionDetailsFilterState();
}

class _SessionDetailsFilterState extends State<SessionDetailsFilter> {
  final HomeController homeController = Get.find();
  final ExchangeRatesController exchangeRatesController = Get.find();
  final SessionController sessionController = Get.find();

  int selectedFilterOption = 1;

  @override
  void initState() {
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack(
      withUsd: false,
    );
    // sessionController.sessionsList = [];
    sessionController.getSessionsFromBack();
    super.initState();
    selectedFilterOption = 1;
    sessionController.selectedCurrencyId = '';
    selectedFilterOption = 1;
    sessionController.fromDateController.clear();
    sessionController.toDateController.clear();
    sessionController.fromSessionController.clear();
    sessionController.toSessionController.clear();
    sessionController.sessionNumberController.clear();
    sessionController.currencyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var sizeBoxWidth = homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.8:MediaQuery.of(context).size.width * 0.35;
    var menuWidth =homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5: MediaQuery.of(context).size.width * 0.2;
    var radioBtnWidth = MediaQuery.of(context).size.width * 0.15;
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
      child: GetBuilder<SessionController>(
        builder: (sessionCont) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(text: 'sessions_details'.tr),
              // gapH32,
              // const AddPhotoCircle(),
              gapH32,
              const Text('Filter sessions as:'),
              homeController.isMobile.value
                  ? Column(
                    children: [
                      SizedBox(
                        // width: radioBtnWidth,
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
                        // width: menuWidth,
                        child: ListTile(
                          title: Text(
                            'sessions_numbers'.tr,
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
                      SizedBox(
                        // width: menuWidth,
                        child: ListTile(
                          title: Text(
                            'single_session_number'.tr,
                            style: const TextStyle(fontSize: 12),
                          ),
                          leading: Radio(
                            value: 3,
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
                  )
                  : Row(
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
                            'sessions_numbers'.tr,
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
                      SizedBox(
                        width: menuWidth,
                        child: ListTile(
                          title: Text(
                            'single_session_number'.tr,
                            style: const TextStyle(fontSize: 12),
                          ),
                          leading: Radio(
                            value: 3,
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
              selectedFilterOption == 1
                  ? Column(
                    children: [
                      SizedBox(
                        width: sizeBoxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('from_date'.tr),
                            DialogDateTextField(
                              textEditingController:
                                  sessionCont.fromDateController,
                              text: '',
                              textFieldWidth: menuWidth,
                              validationFunc: (val) {},
                              onChangedFunc: (val) {
                                sessionCont.fromDateController.text = val;
                              },
                              onDateSelected: (value) {
                                sessionCont.fromDateController.text = value;
                                sessionCont.fromSessionController.clear();
                                sessionCont.sessionNumberController.clear();
                                sessionCont.toSessionController.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                      gapH10,
                      SizedBox(
                        width: sizeBoxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('to_date'.tr),
                            DialogDateTextField(
                              textEditingController:
                                  sessionCont.toDateController,
                              text: '',
                              textFieldWidth: menuWidth,
                              validationFunc: (val) {},
                              onChangedFunc: (val) {
                                sessionCont.toDateController.text = val;
                              },
                              onDateSelected: (value) {
                                sessionCont.toDateController.text = value;
                                sessionCont.fromSessionController.clear();
                                sessionCont.sessionNumberController.clear();
                                sessionCont.toSessionController.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : selectedFilterOption == 2
                  ? SizedBox(
                    child:
                        sessionCont.isSessionsFetched
                            ? Column(
                              children: [
                                SizedBox(
                                  width: sizeBoxWidth,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('from_session_number'.tr),
                                      DropdownMenu<String>(
                                        width: menuWidth,
                                        // requestFocusOnTap: false,
                                        enableSearch: true,
                                        controller:
                                            sessionCont.fromSessionController,
                                        hintText: '',
                                        inputDecorationTheme: InputDecorationTheme(
                                          // filled: true,
                                          hintStyle: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
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
                                            borderRadius:
                                                const BorderRadius.all(
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
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(9),
                                                ),
                                          ),
                                        ),
                                        // menuStyle: ,
                                        menuHeight: 250,
                                        dropdownMenuEntries:
                                            sessionCont.sessionsNumbers.map<
                                              DropdownMenuEntry<String>
                                            >((String option) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            }).toList(),
                                        enableFilter: true,
                                        onSelected: (String? val) {
                                          sessionCont
                                              .fromSessionController
                                              .text = val!;
                                          sessionCont.fromDateController
                                              .clear();
                                          sessionCont.sessionNumberController
                                              .clear();
                                          sessionCont.toDateController.clear();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                gapH10,
                                SizedBox(
                                  width: sizeBoxWidth,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('to_session_number'.tr),
                                      DropdownMenu<String>(
                                        width: menuWidth,
                                        // requestFocusOnTap: false,
                                        enableSearch: true,
                                        controller:
                                            sessionCont.toSessionController,
                                        hintText: '',
                                        inputDecorationTheme: InputDecorationTheme(
                                          // filled: true,
                                          hintStyle: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
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
                                            borderRadius:
                                                const BorderRadius.all(
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
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(9),
                                                ),
                                          ),
                                        ),
                                        // menuStyle: ,
                                        menuHeight: 250,
                                        dropdownMenuEntries:
                                            sessionCont.sessionsNumbers.map<
                                              DropdownMenuEntry<String>
                                            >((String option) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            }).toList(),
                                        enableFilter: true,
                                        onSelected: (String? val) {
                                          sessionCont.toSessionController.text =
                                              val!;
                                          sessionCont.fromDateController
                                              .clear();
                                          sessionCont.sessionNumberController
                                              .clear();
                                          sessionCont.toDateController.clear();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : loading(),
                  )
                  : selectedFilterOption == 3
                  ? SizedBox(
                    width: sizeBoxWidth,
                    child:
                        sessionCont.isSessionsFetched
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('session_number'.tr),
                                DropdownMenu<String>(
                                  width: menuWidth,
                                  // requestFocusOnTap: false,
                                  enableSearch: true,
                                  controller:
                                      sessionCont.sessionNumberController,
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
                                      sessionCont.sessionsNumbers
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
                                    sessionCont.sessionNumberController.text =
                                        val!;
                                    sessionCont.fromSessionController.clear();
                                    sessionCont.toSessionController.clear();
                                    sessionCont.fromDateController.clear();
                                    sessionCont.toDateController.clear();
                                  },
                                ),
                              ],
                            )
                            : loading(),
                  )
                  : const SizedBox(),
              gapH16,
              SizedBox(
                width: sizeBoxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('currency'.tr),
                    GetBuilder<ExchangeRatesController>(
                      builder: (cont) {
                        return cont.isExchangeRatesFetched
                            ? DropdownMenu<String>(
                              width: menuWidth,
                              // requestFocusOnTap: false,
                              enableSearch: true,
                              controller: sessionCont.currencyController,
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
                                  cont.currenciesNamesList
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
                                  var index = cont.currenciesNamesList.indexOf(
                                    val!,
                                  );
                                  sessionCont.setSelectedCurrency(
                                    cont.currenciesIdsList[index],
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
                        selectedFilterOption = 1;
                        sessionCont.selectedCurrencyId = '';
                        selectedFilterOption = 1;
                        sessionCont.currencyController.clear();
                        sessionCont.fromDateController.clear();
                        sessionCont.toDateController.clear();
                        sessionCont.fromSessionController.clear();
                        sessionCont.toSessionController.clear();
                        sessionCont.sessionNumberController.clear();
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
                      if (selectedFilterOption == 1 &&
                          sessionCont.fromDateController.text.isEmpty) {
                        CommonWidgets.snackBar(
                          'error',
                          'From date is required',
                        );
                      } else if (selectedFilterOption == 1 &&
                          sessionCont.toDateController.text.isEmpty) {
                        CommonWidgets.snackBar('error', 'To date is required');
                      } else if (selectedFilterOption == 2 &&
                          sessionCont.fromSessionController.text.isEmpty)
                      {
                        CommonWidgets.snackBar(
                          'error',
                          'From Session is required',
                        );
                      } else if (selectedFilterOption == 2 &&
                          sessionCont.toSessionController.text.isEmpty) {
                        CommonWidgets.snackBar(
                          'error',
                          'To Session is required',
                        );
                      } else if (selectedFilterOption == 3 &&
                          sessionCont.sessionNumberController.text.isEmpty) {
                        CommonWidgets.snackBar(
                          'error',
                          'Session Number is required',
                        );
                      } else if (sessionCont.currencyController.text.isEmpty) {
                        CommonWidgets.snackBar('error', 'Currency is required');
                      } else {
                        await sessionCont.getSessionsDetailsFromBack();
                        if (sessionCont.errorMessage == '') {
                          homeController.selectedTab.value =
                              'session_details_after_filter';
                        } else {
                          CommonWidgets.snackBar(
                            'error',
                            sessionCont.errorMessage,
                          );
                        }
                      }
                    },
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
