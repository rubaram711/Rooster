import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';

import '../../../Controllers/home_controller.dart';
import '../../../Widgets/table_item.dart';
import '../../../Widgets/table_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../../const/functions.dart';
// import 'create_product_dialog.dart';

List transactionQuantitiesList=[
  {'transaction':'Physical on hand','quantities':''},
  {'transaction':'Quantity owned','quantities':''},
  {'transaction':'Ordered not invoiced','quantities':'0 Pcs'}//
  ,{'transaction':'delivered not invoiced','quantities':'0 Pcs'}
  ,{'transaction':'Physical on hand','quantities':'0 Pcs'}
  ,{'transaction':'Ordered not delivered','quantities':'0 Pcs'}//
  ,{'transaction':'Ordered not delivered','quantities':'0 Pcs'}
  ,{'transaction':'received not purchased','quantities':'0 Pcs'}
  ,{'transaction':'purchased not received','quantities':'0 Pcs'}
 , {'transaction':'ordered not purchased','quantities':'0 Pcs'}
  ,{'transaction':'shipped in not received','quantities':'0 Pcs'}
  ,{'transaction':'requisitions not transferred','quantities':'0 Pcs'}
  ,{'transaction':'Quantity to order hand','quantities':'0 Pcs'}
  ,{'transaction':'Global minimum quantity','quantities':'0 Pcs'}
  ,{'transaction':'Global maximum quantity','quantities':'0 Pcs'}
];


TextEditingController quantityController = TextEditingController();
final _formKey=GlobalKey<FormState>();
class QuantitiesTabContent extends StatefulWidget {
  const QuantitiesTabContent({super.key});

  @override
  State<QuantitiesTabContent> createState() => _QuantitiesTabContentState();
}

class _QuantitiesTabContentState extends State<QuantitiesTabContent> {
  ProductController productController = Get.find();

  // getQuantities()async{
  //   var res=await getQuantitiesOfProduct(productController.selectedProductId.toString());
  //   if(res['success']==true){
  //   setState(() {
  //     transactionQuantitiesList[2]['quantities']='${res['data']['salesOrderQuantities']} Pcs';
  //     transactionQuantitiesList[5]['quantities']='${res['data']['salesOrderQuantities']} Pcs';
  //   });
  //   }
  // }
  @override
  void initState() {
    if(!productController.isItUpdateProduct){
      transactionQuantitiesList[0]['quantities'] = '';
      transactionQuantitiesList[1]['quantities'] = '';
      transactionQuantitiesList[2]['quantities'] = '';
      transactionQuantitiesList[5]['quantities'] = '';
    }
    // getQuantities();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
        builder: (cont) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
          child: Form(
            key:_formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gapH28,
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('transactional_quantity'.tr,style: TextStyle(fontWeight: FontWeight.bold,color:TypographyColor.titleTable),),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                color: Primary.primary,
                                borderRadius: const BorderRadius.all(Radius.circular(6))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TableTitle(
                                  text: 'transaction'.tr,
                                  width: MediaQuery.of(context).size.width * 0.13,
                                ),
                                TableTitle(
                                  text: 'quantity'.tr,
                                  width: MediaQuery.of(context).size.width * 0.07,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: ListView.builder(
                              itemCount: transactionQuantitiesList.length, //products is data from back res
                              itemBuilder: (context, index) => TransactionalQuantitiesRowInTable(
                                isDesktop: true,
                                data: transactionQuantitiesList[index],
                                index: index,
                              ),
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.43,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('warehouses'.tr,style: TextStyle(fontWeight: FontWeight.bold,color:TypographyColor.titleTable),),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(  vertical: 15),
                              decoration: BoxDecoration(
                                  color: Primary.primary,
                                  borderRadius: const BorderRadius.all(Radius.circular(6))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TableTitle(
                                    text: 'code'.tr,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                  ),
                                  TableTitle(
                                    text: 'name'.tr,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                  ),
                                  TableTitle(
                                    text: 'shelving'.tr,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                  ),
                                  TableTitle(
                                    text: '${'quantity'.tr} (in piece)',
                                    width: MediaQuery.of(context).size.width * 0.1,
                                  ),
                                  TableTitle(
                                    text: 'blocked'.tr,
                                    width: MediaQuery.of(context).size.width * 0.08,
                                  ),
                                ],
                              ),
                            ),
                            cont.isItUpdateProduct?   Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: ListView.builder(
                                itemCount: cont.warehousesList.length, //products is data from back res
                                itemBuilder: (context, index) => WarehousesAsRowInTable(
                                  data: cont.warehousesList[index],
                                  index: index,
                                ),
                              ),
                            ):  SizedBox(height: MediaQuery.of(context).size.height * 0.45),
                          ],
                        )
                    ),
                  ],
                ),
                // const Spacer(),
                // ReusableBTNsRow(
                //   onBackClicked: (){
                //     cont.setSelectedTabIndex(4);
                //   },
                //   onDiscardClicked: (){
                //     quantityController.clear();
                //   },
                //   onNextClicked: (){
                //     if(_formKey.currentState!.validate()){
                //       cont.setSelectedTabIndex(6);
                //     }
                //   },
                //   onSaveClicked: (){},
                // )
              ],
            ),
          ),
        );
      }
    );
  }
}

class TransactionalQuantitiesRowInTable extends StatelessWidget {
  const TransactionalQuantitiesRowInTable({super.key, required this.data, required this.index, required this.isDesktop});
  final Map data;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(  vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width:isDesktop? MediaQuery.of(context).size.width * 0.13:MediaQuery.of(context).size.width * 0.4,
            child: Text('   ${data['transaction'] ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: TypographyColor.textTable,
                )),
          ),
          TableItem(
            text: data['quantities']!=null?numberWithComma('${data['quantities']}'): '',
            width: isDesktop?MediaQuery.of(context).size.width * 0.07:MediaQuery.of(context).size.width * 0.3,
          ),
        ],
      ),
    );
  }
}

class WarehousesAsRowInTable extends StatefulWidget {
  const WarehousesAsRowInTable({super.key, required this.data, required this.index});
  final Map data;
  final int index;

  @override
  State<WarehousesAsRowInTable> createState() => _WarehousesAsRowInTableState();
}

class _WarehousesAsRowInTableState extends State<WarehousesAsRowInTable> {
  bool isWarehousesChecked=false;
  HomeController homeController=Get.find();
  TextEditingController shelvingTextEditingController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(  vertical: 10),
      decoration: BoxDecoration(
          color: (widget.index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: '${widget.data['warehouse_number'] ?? ''}',
            width:homeController.isMobile.value?140: MediaQuery.of(context).size.width * 0.08,
          ),
          TableItem(
            text: '${widget.data['name'] ?? ''}',
            width:homeController.isMobile.value?140:  MediaQuery.of(context).size.width * 0.08,
          ),
          SizedBox(
            width:homeController.isMobile.value?140:  MediaQuery.of(context).size.width * 0.08,
            child: ReusableTextField(
                onChangedFunc: (val){},
                validationFunc: (val){}, hint: '',
                isPasswordField: false,
                textEditingController: shelvingTextEditingController),
          ),
          // TableItem(
          //   text: '${widget.data['shelving'] ?? ''}',
          //   width:homeController.isMobile.value?140:  MediaQuery.of(context).size.width * 0.08,
          // ),
          TableItem(
            text: widget.data['qty_on_hand']!=null?numberWithComma('${widget.data['qty_on_hand']}'): '',
            width:homeController.isMobile.value?200:  MediaQuery.of(context).size.width * 0.1,
          ),
          SizedBox(
            width:homeController.isMobile.value?100:  MediaQuery.of(context).size.width * 0.08,
            child: Checkbox(
              // checkColor: Colors.white,
              // fillColor: MaterialStateProperty.resolveWith(getColor),
              value: isWarehousesChecked,
              onChanged: (bool? value) {
                // setState(() {
                //   isWarehousesChecked = value!;
                // });
              },
            ),
          ),
        ],
      ),
    );
  }
}




// class MobileQuantitiesTabContent extends StatefulWidget {
//   const MobileQuantitiesTabContent({super.key});
//
//   @override
//   State<MobileQuantitiesTabContent> createState() => _MobileQuantitiesTabContentState();
// }
//
// class _MobileQuantitiesTabContentState extends State<MobileQuantitiesTabContent> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ProductController>(
//       builder: (cont) {
//         return SizedBox(
//           height: MediaQuery.of(context).size.height * 0.55,
//           child: ListView(
//             children: [
//               SizedBox(
//                   // width: MediaQuery.of(context).size.width * 0.2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('transactional_quantity'.tr,style: TextStyle(fontWeight: FontWeight.bold,color:TypographyColor.titleTable),),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.03,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         decoration: BoxDecoration(
//                             color: Primary.primary,
//                             borderRadius: const BorderRadius.all(Radius.circular(6))),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             TableTitle(
//                               text: 'transaction'.tr,
//                               width: MediaQuery.of(context).size.width * 0.4,
//                             ),
//                             TableTitle(
//                               text: 'quantity'.tr,
//                               width: MediaQuery.of(context).size.width * 0.3,
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         color: Colors.white,
//                         height: transactionQuantitiesList.length*200,
//                         // height: MediaQuery.of(context).size.height * 0.4,
//                         child: ListView.builder(
//                           itemCount: transactionQuantitiesList.length, //products is data from back res
//                           itemBuilder: (context, index) => TransactionalQuantitiesRowInTable(
//                             isDesktop: false,
//                             data: transactionQuantitiesList[index],
//                             index: index,
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//               ),
//               gapH32,
//               SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('warehouses'.tr,style: TextStyle(fontWeight: FontWeight.bold,color:TypographyColor.titleTable),),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(  vertical: 15),
//                         decoration: BoxDecoration(
//                             color: Primary.primary,
//                             borderRadius: const BorderRadius.all(Radius.circular(6))),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             TableTitle(
//                               text: 'code'.tr,
//                               width: MediaQuery.of(context).size.width * 0.08,
//                             ),
//                             TableTitle(
//                               text: 'name'.tr,
//                               width: MediaQuery.of(context).size.width * 0.08,
//                             ),
//                             TableTitle(
//                               text: 'shelving'.tr,
//                               width: MediaQuery.of(context).size.width * 0.08,
//                             ),
//                             TableTitle(
//                               text: '${'quantity'.tr}(in piece)',
//                               width: MediaQuery.of(context).size.width * 0.08,
//                             ),
//                             TableTitle(
//                               text: 'blocked'.tr,
//                               width: MediaQuery.of(context).size.width * 0.08,
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         color: Colors.white,
//                         height: MediaQuery.of(context).size.height * 0.5,
//                         child: ListView.builder(
//                           itemCount: cont.warehousesList.length, //products is data from back res
//                           itemBuilder: (context, index) => WarehousesAsRowInTable(
//                             data: cont.warehousesList[index],
//                             index: index,
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//               ),
//               // const Spacer(),
//               ReusableBTNsRow(
//                 onBackClicked: (){
//                   cont.setSelectedTabIndex(4);
//                 },
//                 onDiscardClicked: (){
//                   quantityController.clear();
//                 },
//                 onNextClicked: (){
//                   if(_formKey.currentState!.validate()){
//                     cont.setSelectedTabIndex(6);
//                   }
//                 },
//                 onSaveClicked: (){},
//               )
//             ],
//           ),
//         );
//       }
//     );
//   }
// }


class MobileQuantitiesTabContent extends StatefulWidget {
  const MobileQuantitiesTabContent({super.key});

  @override
  State<MobileQuantitiesTabContent> createState() => _MobileQuantitiesTabContentState();
}

class _MobileQuantitiesTabContentState extends State<MobileQuantitiesTabContent> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransactionalQuantitiesSection(context),
                _buildWarehousesSection(context, cont),
                SizedBox(height: 32),
                // ReusableBTNsRow(
                //   onBackClicked: () {
                //     cont.setSelectedTabIndex(4);
                //   },
                //   onDiscardClicked: () {
                //     quantityController.clear();
                //   },
                //   onNextClicked: () {
                //     if (_formKey.currentState!.validate()) {
                //       cont.setSelectedTabIndex(6);
                //     }
                //   },
                //   onSaveClicked: () {},
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionalQuantitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactional_quantity'.tr,
          style: TextStyle(fontWeight: FontWeight.bold, color: TypographyColor.titleTable),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Primary.primary,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TableTitle(
                text: 'transaction'.tr,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              TableTitle(
                text: 'quantity'.tr,
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: transactionQuantitiesList.length * 45,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactionQuantitiesList.length,
            itemBuilder: (context, index) => TransactionalQuantitiesRowInTable(
              isDesktop: false,
              data: transactionQuantitiesList[index],
              index: index,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarehousesSection(BuildContext context, ProductController cont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'warehouses'.tr,
          style: TextStyle(fontWeight: FontWeight.bold, color: TypographyColor.titleTable),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
       SingleChildScrollView(
            child: Row(
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            // horizontal: 10,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Primary.primary,
                            borderRadius:
                            const BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                          child: Row(
                            children: [
                              TableTitle(
                                text: 'code'.tr,
                                width: 140,
                              ),
                              TableTitle(
                                text: 'name'.tr,
                                width: 140,
                              ),
                              TableTitle(
                                text: 'shelving'.tr,
                                width: 140,
                              ),
                              TableTitle(
                                text: '${'quantity'.tr}(in piece)',
                                width: 200,
                              ),
                              TableTitle(
                                text: 'blocked'.tr,
                                width:100,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: List.generate(
                              cont.warehousesList.length,
                                  (index) =>
                                      WarehousesAsRowInTable(
                                        data: cont.warehousesList[index],
                                        index: index,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
