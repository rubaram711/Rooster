import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/combo_controller.dart';
import 'package:rooster_app/Screens/Combo/ComboSummaryWidgets/ItemsOptions/update_item.dart';
import 'package:rooster_app/Screens/Transfers/Replenish/replenishment.dart';
import 'package:rooster_app/Widgets/custom_snak_bar.dart';
import 'package:rooster_app/Widgets/dialog_title.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import 'package:rooster_app/Widgets/table_title.dart';
import 'package:rooster_app/const/colors.dart';
import 'package:rooster_app/const/sizes.dart';

class ShowItemsComboDialog extends StatelessWidget {
  const ShowItemsComboDialog({super.key, required this.info});

  final Map info;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ComboController>(
      builder:
          (cont) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.width * 0.80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DialogTitle(text: 'Items of ${info['name']} '),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: CircleAvatar(
                        backgroundColor: Primary.primary,
                        radius: 15,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH20,
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Primary.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TableTitle(
                        isCentered: false,
                        text: 'name'.tr,
                        width: MediaQuery.of(context).size.width * 0.10,
                      ),
                      TableTitle(
                        isCentered: false,
                        text: 'description'.tr,
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      TableTitle(
                        isCentered: false,
                        text: 'quantity'.tr,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      TableTitle(
                        isCentered: false,
                        text: 'price'.tr,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),

                      TableTitle(
                        isCentered: false,
                        text: 'currency'.tr,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      TableTitle(
                        isCentered: false,
                        text: 'more_options'.tr,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: info['items'].length, // data from back
                    itemBuilder: (context, i) {
                      return ShowitemquantityAsRow(
                        isDesktop: true,
                        itemName: info['items'][i]['item_name'],
                        itemDescription: info['items'][i]['mainDescription'],
                        itemquantity: '${info['items'][i]['quantity']}',
                        itemPrice: '${info['items'][i]['unitPrice']}',
                        itemCurrency: '${info['items'][i]['currency']['name']}',
                      );
                    },
                  ),
                ),
              ],
            ),
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
          TableItem(
            isCentered: false,
            text: itemName,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.10 : 100,
          ),
          TableItem(
            isCentered: false,
            text: itemDescription,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.15 : 150,
          ),
          TableItem(
            isCentered: false,
            text: itemquantity,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.07 : 100,
          ),
          TableItem(
            isCentered: false,
            text: itemPrice,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.07 : 100,
          ),
          TableItem(
            isCentered: false,
            text: itemCurrency,
            width: isDesktop ? MediaQuery.of(context).size.width * 0.07 : 100,
          ),
          //****reusablo more *******************/
          GetBuilder<ComboController>(
            builder: (cont) {
              return SizedBox(
                width:
                    isDesktop ? MediaQuery.of(context).size.width * 0.07 : 70,
                child: ReusableMore(
                  itemsList: [
                    PopupMenuItem<String>(
                      value: '1',
                      onTap: () {
                        //UpdateItem(quantity: itemquantity);
                        showDialog<String>(
                          context: context,
                          builder:
                              (BuildContext context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(9),
                                  ),
                                ),
                                elevation: 0,
                                content: UpdateItem(quantity: itemquantity),
                              ),
                        );
                      },
                      child: Text('updat_quantity'.tr),
                    ),
                    PopupMenuItem<String>(
                      value: '2',
                      onTap: () {
                        CommonWidgets.snackBar(
                          'Success',
                          'Deleted Successfully',
                        );
                      },
                      child: Text('delete'.tr),
                    ),
                  ],
                ),
              );
            },
          ),

          //***************** */
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        ],
      ),
    );
  }
}
