import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import 'package:rooster_app/Widgets/table_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

class ComboData extends StatefulWidget {
  const ComboData({super.key});

  @override
  State<ComboData> createState() => _ComboDataState();
}

class _ComboDataState extends State<ComboData> {
  ComboController comboController = Get.find();

  TextEditingController comboNameController = TextEditingController();
  TextEditingController comboPriceController = TextEditingController();
  TextEditingController comboCurrenceController = TextEditingController();
  TextEditingController comboCodeController = TextEditingController();
  TextEditingController comboMainDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List info = comboController.selectedComboData['items'];

    comboCodeController = TextEditingController(
      text: comboController.selectedComboData['code'],
    );
    comboNameController = TextEditingController(
      text: comboController.selectedComboData['name'],
    );
    comboPriceController = TextEditingController(
      text: comboController.selectedComboData['price'],
    );
    comboCurrenceController = TextEditingController(
      text: comboController.selectedComboData['currency']['name'],
    );
    comboMainDescriptionController = TextEditingController(
      text: comboController.selectedComboData['description'],
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "combo_details".tr,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.00,
                ),
              ),
              gapW100,
            ],
          ),
          gapH16,
          Text("Combo's Name"),
          gapH10,
          ReusableTextField(
            isEnable: false,
            onChangedFunc: () {},

            validationFunc: () {},
            hint: '',
            isPasswordField: false,
            textEditingController: comboNameController,
          ),
          gapH10,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTextField(
                read: true,

                textEditingController: comboCodeController,
                text: 'combo_code'.tr,
                rowWidth: MediaQuery.of(context).size.width * 0.30,
                textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                validationFunc: (value) {
                  if (value.isEmpty) {
                    return 'required_field'.tr;
                  }
                  return null;
                },
              ),
              DialogNumericTextField(
                read: true,
                hint: comboController.selectedComboData['price'],
                validationFunc: () {},
                text: "Price",
                rowWidth: MediaQuery.of(context).size.width * 0.30,
                textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                textEditingController: comboPriceController,
              ),
            ],
          ),
          gapH10,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogNumericTextField(
                read: true,
                validationFunc: () {},
                text: "Currency",
                rowWidth: MediaQuery.of(context).size.width * 0.30,
                textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                textEditingController: comboCurrenceController,
              ),
              DialogTextField(
                read: true,
                validationFunc: () {},
                text: "Main Description",
                rowWidth: MediaQuery.of(context).size.width * 0.30,
                textFieldWidth: MediaQuery.of(context).size.width * 0.20,
                textEditingController: comboMainDescriptionController,
              ),
            ],
          ),
          gapH20,
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Primary.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    gapW16,
                    TableTitle(
                      text: 'item_code'.tr,
                      isCentered: false,
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),

                    TableTitle(
                      text: 'description'.tr,
                      isCentered: false,
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),

                    TableTitle(
                      text: 'quantity'.tr,
                      isCentered: false,
                      width: MediaQuery.of(context).size.width * 0.10,
                    ),
                    TableTitle(
                      text: 'unit_price'.tr,
                      isCentered: false,
                      width: MediaQuery.of(context).size.width * 0.10,
                    ),
                    TableTitle(
                      text: 'currency'.tr,
                      isCentered: false,
                      width: MediaQuery.of(context).size.width * 0.10,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  ],
                ),
              ),
              //********************************Section Table Row********************************************* */
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //+++++++++++++++++Rows in table With SingleScrollView+++++++++++++++++++++++++++++++
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: SingleChildScrollView(
                        child: Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: info.length, // data from back
                            itemBuilder: (context, i) {
                              return ShowitemquantityAsRow(
                                isDesktop: true,
                                itemName: info[i]['item_name'],
                                itemDescription: info[i]['mainDescription'],
                                itemquantity: '${info[i]['quantity']}',
                                itemPrice: '${info[i]['unitPrice']}',
                                itemCurrency: '${info[i]['currency']['name']}',
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    //++++++++++++++++++++++++++++++++++++++++++++++++
                    gapH10,
                  ],
                ),
              ),
              //**************************************************************************** */
            ],
          ),
        ],
      ),
    );
  }
}

class ShowitemquantityAsRow extends StatelessWidget {
  const ShowitemquantityAsRow({
    super.key,
    required this.isDesktop,
    required this.itemName,
    required this.itemquantity,
    required this.itemDescription,
    required this.itemPrice,
    required this.itemCurrency,
  });
  //final Map info;
  final String itemName;
  final String itemDescription;
  final String itemquantity;
  final String itemPrice;
  final String itemCurrency;

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.02,
            height: 20,
            margin: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/newRow.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          TableItem(
            isCentered: false,
            text: itemName,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.10 : 150,
          ),
          TableItem(
            isCentered: false,
            text: itemDescription,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 150,
          ),
          TableItem(
            isCentered: false,
            text: itemquantity,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.10 : 100,
          ),
          TableItem(
            isCentered: false,
            text: itemPrice,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.10 : 100,
          ),
          TableItem(
            isCentered: false,
            text: itemCurrency,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.10 : 100,
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.07),
        ],
      ),
    );
  }
}
