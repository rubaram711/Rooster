import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Screens/Products/barcode_scanner.dart';
import 'package:rooster_app/const/colors.dart';
import '../../Backend/CategoriesBackend/get_categories.dart';
import '../../Backend/ProductsBackend/delete_product.dart';
import '../../Controllers/products_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/functions.dart';
import 'CreateProductDialog/create_product_dialog.dart';
import 'edit_price_dialog.dart';


TextEditingController searchControllerInProductsPage = TextEditingController();

enum FilterItems {
  // taxationGroups('taxation_groups', '/Taxation_groups'),
  // subReferences('sub_references', '/sub_references'),
  // groups('groups', '/groups'),
  // salesmen('salesmen', '/salesmen'),
  // warehouses('warehouses', '/warehouses'),
  priceLists('', '/price_lists');

  const FilterItems(this.label, this.route);
  final String label;
  final String route;
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController filterController = TextEditingController();
  FilterItems? selectedFilterItem;

  List<String> categoriesNameList = ['all_categories'.tr];
  String? selectedItem = '';
  List categoriesIds = ['0'];
  bool isCategoriesFetched = false;
  getCategoriesFromBack() async {
    var p = await getCategories('');
    setState(() {
      for (var item in p) {
        categoriesNameList.add('${item['category_name']}');
        categoriesIds.add('${item['id']}');
        isCategoriesFetched = true;
      }
    });
  }

  ProductController productController = Get.find();
  // List productsList = [];
  // bool isProductsFetched = false;
  // getAllProductsFromBack() async {
  //   setState(() {
  //     productsList = [];
  //   });
  //   var p = await getAllProducts(searchController.text,selectedCategoryId=='0'?'': selectedCategoryId);
  //   setState(() {
  //     productsList.addAll(p);
  //     isProductsFetched = true;
  //   });
  // }
  // Function to scan barcode

  final ScrollController scrollController=ScrollController();



  @override
  void initState() {
    productController.productsList.value = [].obs;
    productController.currentPage.value=1;
    scrollController.addListener(() {
      if(scrollController.position.pixels>=scrollController.position.maxScrollExtent && !productController.isLoading.value){
        productController.getAllProductsFromBack();
      }
    },);
    getCategoriesFromBack();
    productController.productsList.value = [].obs;
    productController.getAllProductsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        // child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageTitle(text: 'products'.tr),
                  ReusableButtonWithColor(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: 45,
                    onTapFunction: () {
                      productController.clearData();
                      productController.getFieldsForCreateProductFromBack();
                      productController.setIsItUpdateProduct(false);
                      showDialog<String>(
                        context: context,
                        builder:
                            (BuildContext context) => const AlertDialog(
                              backgroundColor: Colors.white,
                              contentPadding: EdgeInsets.all(0),
                              titlePadding: EdgeInsets.all(0),
                              actionsPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9),
                                ),
                              ),
                              elevation: 0,
                              content: CreateProductDialogContent(),
                            ),
                      );
                    },
                    btnText: 'create_new_product'.tr,
                  ),
                ],
              ),
              gapH16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: ReusableSearchTextField(
                      hint: '${"search".tr}...',
                      textEditingController: searchControllerInProductsPage,
                      onChangedFunc: (val) {},
                      validationFunc: (val) {},
                    ),
                  ),
                  // DropdownMenu<FilterItems>(
                  //   width: MediaQuery.of(context).size.width * 0.08,
                  //   // initialSelection: configItems.green,
                  //   requestFocusOnTap: false,
                  //   inputDecorationTheme: InputDecorationTheme(
                  //     // filled: true,
                  //     contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 3),
                  //     // outlineBorder: BorderSide(color: Colors.black,),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderSide:
                  //           BorderSide(color: Primary.primary, width: 1),
                  //       borderRadius:
                  //           const BorderRadius.all(Radius.circular(9)),
                  //     ),
                  //   ),
                  //   controller: filterController,
                  //   label: Text(
                  //     'filter_by'.tr,
                  //     style: TextStyle(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.bold,
                  //         color: Primary.primary),
                  //   ),
                  //   // menuStyle: ,
                  //   dropdownMenuEntries: FilterItems.values
                  //       .map<DropdownMenuEntry<FilterItems>>(
                  //           (FilterItems filter) {
                  //     return DropdownMenuEntry<FilterItems>(
                  //       value: filter,
                  //       label: filter.label,
                  //       enabled: filter.label != 'Grey',
                  //       // style: MenuItemButton.styleFrom(
                  //       // foregroundColor: color.color,
                  //       // ),
                  //     );
                  //   }).toList(),
                  //   onSelected: (FilterItems? val) {
                  //     setState(() {
                  //       selectedFilterItem = val;
                  //     });
                  //   },
                  // ),
                  // InkWell(
                  //   key: accKey,
                  //   onTap: () {
                  //     // if (val == true) {
                  //     final RenderBox renderBox = accKey.currentContext
                  //         ?.findRenderObject() as RenderBox;
                  //     final Size size = renderBox.size;
                  //     final Offset offset =
                  //         renderBox.localToGlobal(Offset.zero);
                  //     showMenu(
                  //       context: context,
                  //       color: Colors.white, //TypographyColor.menuBg,
                  //       surfaceTintColor: Colors.white,
                  //       position: RelativeRect.fromLTRB(
                  //           offset.dx,
                  //           offset.dy + size.height + 15,
                  //           offset.dx + size.width,
                  //           offset.dy + size.height),
                  //       items: [
                  //         PopupMenuItem<String>(
                  //             value: '1', child: Text('duplicate'.tr)),
                  //         PopupMenuItem<String>(
                  //             value: '2', child: Text('delete'.tr)),
                  //         PopupMenuItem<String>(
                  //             value: '3', child: Text('edit'.tr)),
                  //       ],
                  //     );
                  //   },
                  //   child: Icon(
                  //     Icons.settings_rounded,
                  //     color: TypographyColor.textTable,
                  //   ),
                  // ),
                  DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width * 0.12,
                    requestFocusOnTap: false,
                    hintText: 'all_categories'.tr,
                    inputDecorationTheme: InputDecorationTheme(
                      // filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      // outlineBorder: BorderSide(color: Colors.black,),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                    ),
                    dropdownMenuEntries:
                        categoriesNameList.map<DropdownMenuEntry<String>>((
                          String option,
                        ) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                          );
                        }).toList(),
                    onSelected: (String? val) {
                      setState(() {
                        selectedItem = val!;
                        var index = categoriesNameList.indexOf(val);
                        productController
                            .selectedCategoryIdInProductPage
                            .value = categoriesIds[index];
                      });
                    },
                  ),
                  Tooltip(
                    message: 'Click to search',
                    child: InkWell(
                      onTap: () async {
                        productController.productsList.value = [].obs;
                        await productController.getAllProductsFromBackWithSearch();
                      },
                      child: Icon(Icons.search, color: Primary.primary),
                    ),
                  ),
                  Tooltip(
                    message: 'Grid View',
                    child: InkWell(
                      onTap: () {
                        productController.isGrid.value =
                            !productController.isGrid.value;
                      },
                      child: Icon(
                        Icons.grid_view_outlined,
                        color:
                            productController.isGrid.value
                                ? Primary.primary
                                : TypographyColor.textTable,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'List View',
                    // decoration: BoxDecoration(
                    //   color: Colors.black,
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    // textStyle: TextStyle(color: Colors.white),
                    // waitDuration: Duration(milliseconds: 500),
                    // showDuration: Duration(seconds: 2),
                    child: InkWell(
                      onTap: () {
                        productController.isGrid.value =
                            !productController.isGrid.value;
                      },
                      child: Icon(
                        Icons.format_list_bulleted,
                        color:
                            productController.isGrid.value
                                ? TypographyColor.textTable
                                : Primary.primary,
                      ),
                    ),
                  ),
                ],
              ),
              gapH32,
              productController.isGrid.value
                  ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child:
                        // productController.isProductsFetched.value ?
                        GridView.count(
                          controller: scrollController,
                              crossAxisCount: 3,
                              childAspectRatio: Sizes.deviceWidth / 720,
                              children: List.generate(
                                productController.productsList.length,
                                (index) {
                                  return _productsCard(
                                    productController.productsList[index],
                                    index,
                                  );
                                },
                              ),
                            )
                            // : const Center(child: CircularProgressIndicator()),
                  ):
                  // : productController.isProductsFetched.value ?
              Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width:  MediaQuery.of(context).size.width * 0.09,
                              child: Text('code'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold)),
                            ),SizedBox(
                              width:  MediaQuery.of(context).size.width * 0.09,
                              child: Text('name'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold)),
                            ),SizedBox(
                              width:  MediaQuery.of(context).size.width * 0.24,
                              child: Text('description'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            // TableTitle(
                            //   text: 'name'.tr,
                            //   width: MediaQuery.of(context).size.width * 0.09,
                            // ),
                            // TableTitle(
                            //   text: 'description'.tr,
                            //   width: MediaQuery.of(context).size.width * 0.24,
                            // ),
                            // TableTitle(
                            //   text: 'qty_on_hand'.tr,
                            //   width:
                            //       MediaQuery.of(context).size.width * 0.07,
                            // ),
                            TableTitle(
                              text: 'price'.tr,
                              width: MediaQuery.of(context).size.width * 0.09,
                            ),
                            TableTitle(
                              text: 'currency'.tr,
                              width: MediaQuery.of(context).size.width * 0.09,
                            ),
                            TableTitle(
                              text: 'on_hand'.tr,
                              width: MediaQuery.of(context).size.width * 0.09,
                            ),
                            // TableTitle(
                            //   text: 'qty_shipped'.tr,
                            //   width:
                            //       MediaQuery.of(context).size.width * 0.07,
                            // ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount:
                              productController
                                  .productsList
                                  .length, //products is data from back res
                          itemBuilder:
                              (context, index) => _productsAsRowInTable(
                                productController.productsList[index],
                                index,
                              ),
                        ),
                      ),
                    ],
                  ),
                  // : const Center(child: CircularProgressIndicator()),
              if(productController.isLoading.value)Padding(padding: EdgeInsets.all(16),child: CircularProgressIndicator(),)
            ],
          ),
        // ),
      ),
    );
  }

  _productsAsRowInTable(Map product, int index) {
    return InkWell(
      onDoubleTap: () {
        productController.setSelectedProductId('${product['id']}');
        productController.clearData();
        productController.getFieldsForCreateProductFromBack();
        productController.setIsItUpdateProduct(true);
        productController.setAllValuesForUpdate(product);
        showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.all(0),
              titlePadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              elevation: 0,
              content: CreateProductDialogContent(),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0)),
        ),
        child: Row(
          children: [
            TableItem(
              isCentered: false,
              text: '${product['mainCode'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.09,
            ),
            TableItem(
              isCentered: false,
              text: '${product['item_name'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.09,
            ),
            TableItem(
              isCentered: false,
              text: '${product['mainDescription'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.24,
            ),
            // TableItem(
            //   text:
            //       '${product['quantity'] ?? ''} ${product['packageSetName'] ?? ''}',
            //   width: MediaQuery.of(context).size.width * 0.07,
            // ),
            TableItem(
              text: product['unitPrice']!=null?numberWithComma('${product['unitPrice']}'): '',
              width: MediaQuery.of(context).size.width * 0.09,
            ),
            TableItem(
              text:
                  product['priceCurrency'] != null
                      ? '${product['priceCurrency']['name'] ?? ''}'
                      : '',
              width: MediaQuery.of(context).size.width * 0.09,
            ),
            TableItem(
              text:
                  '${product['current_quantity']!=null?numberWithComma('${product['current_quantity']}'): ''} ${product['packageSetName'] ?? ''}',
              width: MediaQuery.of(context).size.width * 0.09,
            ),
            // TableItem(
            //   text:
            //       '${product['current_quantity'] ?? ''} ${product['packageSetName'] ?? ''}',
            //   width: MediaQuery.of(context).size.width * 0.07,
            // ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
              child: ReusableMore(
                itemsList: [
                  PopupMenuItem<String>(
                    value: '1',
                    onTap: () async {
                      var res = await deleteProduct('${product['id']}');
                      var p = json.decode(res.body);
                      if (res.statusCode == 200) {
                        CommonWidgets.snackBar('Success', p['message']);
                        setState(() {
                          productController.productsList.removeAt(index);
                        });
                      } else {
                        CommonWidgets.snackBar('error', p['message']);
                      }
                    },
                    child: Text('delete'.tr),
                  ),
                  // PopupMenuItem<String>(
                  //   value: '2',
                  //   onTap: () {
                  //     showDialog<String>(
                  //         context: context,
                  //         builder: (BuildContext context) =>
                  //          AlertDialog(
                  //             backgroundColor:
                  //             Colors.white,
                  //             shape:
                  //             const RoundedRectangleBorder(
                  //               borderRadius:
                  //               BorderRadius.all(
                  //                   Radius.circular(
                  //                       9)),
                  //             ),
                  //             elevation: 0,
                  //             content: EditQuantityDialog(id:'${product['id']}',)));
                  //   },
                  //   child: Text('edit_quantity'.tr),
                  // ),
                  PopupMenuItem<String>(
                    value: '2',
                    onTap: () async {
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
                              content: EditPriceDialog(
                                product: product,
                                id: '${product['id']}',
                                isMobile: false,
                              ),
                            ),
                      );
                    },
                    child: Text('edit_price'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _productsCard(Map product, int index) {
    return InkWell(
      onDoubleTap: () {
        productController.setSelectedProductId('${product['id']}');
        productController.setSelectedProductIndex(index);
        productController.clearData();
        productController.getFieldsForCreateProductFromBack();
        productController.setIsItUpdateProduct(true);
        productController.setAllValuesForUpdate(product);
        showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.all(0),
              titlePadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              elevation: 0,
              content: CreateProductDialogContent(),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ClipPath(
          clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Others.menuBg,
              border: Border(top: BorderSide(color: Primary.primary, width: 3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.7 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          '${product['item_name'] ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Primary.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        children: [
                          // const FavoriteIcon(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03,
                            child: ReusableMore(
                              itemsList: [
                                PopupMenuItem<String>(
                                  value: '1',
                                  onTap: () async {
                                    var res = await deleteProduct(
                                      '${product['id']}',
                                    );
                                    var p = json.decode(res.body);
                                    if (res.statusCode == 200) {
                                      CommonWidgets.snackBar(
                                        'Success',
                                        p['message'],
                                      );
                                      setState(() {
                                        productController.productsList.removeAt(
                                          index,
                                        );
                                      });
                                    } else {
                                      CommonWidgets.snackBar(
                                        'error',
                                        p['message'],
                                      );
                                    }
                                  },
                                  child: Text('delete'.tr),
                                ),
                                PopupMenuItem<String>(
                                  value: '2',
                                  onTap: () async {
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
                                            content: EditPriceDialog(
                                              product: product,
                                              id: '${product['id']}',
                                              isMobile: false,
                                            ),
                                          ),
                                    );
                                  },
                                  child: Text('edit_price'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('[${product['mainCode'] ?? ''}]'),
                          SizedBox(height: Sizes.deviceHeight * 0.01),
                          Text(
                            '${'price'.tr}: ${product['unitPrice']!=null?numberWithComma('${product['unitPrice']}'): ''} ${product['priceCurrency'] != null ? '${product['priceCurrency']['symbol'] ?? ''}' : ''}',
                          ),
                          SizedBox(height: Sizes.deviceHeight * 0.01),
                          Text(
                            '${'on_hand'.tr}: ${product['current_quantity']!=null?numberWithComma('${product['current_quantity']}'): ''} ${product['packageUnitName'] ?? ''}',
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: Image.network(
                          '${product['images']}' == '[]'
                              ?'https://theravenstyle.com/rooster-backend/public/storage/WhatsApp%20Image%202024-03-03%20at%2011.41.15%20AM.jpeg'
                              :'${product['images'][0]}',
                          height: Sizes.deviceHeight * 0.12,
                          width: Sizes.deviceWidth * 0.07,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => loading(),
                          // loadingBuilder: (context, child, loadingProgress) => loading('laod'),
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   height:  MediaQuery.of(context).size.height * 0.05,
                  //     padding: const EdgeInsets.only(right: 15),
                  //     child: CardDescriptionText(
                  //       text: '${product['mainDescription'] ?? ''}',
                  //     )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class ProductsCard extends StatelessWidget {
//   const ProductsCard({super.key, required this.product});
//   final Map product;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: ClipPath(
//         clipper: const ShapeBorderClipper(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(9))
//             )
//         ),
//         child: Container(
//             decoration: BoxDecoration(
//                 color:Others.menuBg,
//                 border: Border(
//                     top: BorderSide(color: Primary.primary, width: 3),
//                 ),
//               boxShadow: [BoxShadow(  color: Colors.grey.withAlpha((0.7 * 255).toInt()),
//                 spreadRadius: 9,
//                 blurRadius: 9,
//                 offset: const Offset(0, 3),)]
//             ),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                    Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: [
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: [
//                            TitleTextInCard(text: product['company'] != null
//                                ? '${product['company']['name'] ?? ''}'
//                                : '',),
//                            Row(
//                              children: [
//                                const FavoriteIcon(),
//                                SizedBox(
//                                  width: MediaQuery.of(context)
//                                      .size
//                                      .width *
//                                      0.03,
//                                  child: ReusableMore(
//                                    itemsList: [PopupMenuItem<String>(
//                                      value: '1',
//                                      onTap: () async {
//                                        var res= await deleteProduct('${ product['id']}');
//                                        if(res.statusCode==200){
//                                          CommonWidgets.snackBar('', 'Product Deleted Successfully');
//                                          setState(() {
//                                            productsList.removeAt(index);
//                                          });
//                                        }else{
//                                          CommonWidgets.snackBar('error',
//                                              'There is an error');
//                                        }
//                                      },
//                                      child: Text('delete'.tr),
//                                    ),],
//                                  ),
//                                )
//                              ],
//                            )
//                          ],
//                        ),
//                   gapH10,
//                   Container(
//                     padding: const EdgeInsets.only(right: 15),
//                       child: CardDescriptionText(text: '${product['mainDescription'] ?? ''}',)),
//                      ],
//                    ),
//                   Column(
//                     children: [
//                       Divider(
//                         color: Others.divider,
//                         // endIndent: MediaQuery.of(context).size.width * 0.15,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TitleTextInCard(text: '${product['unitPrice'] ?? ''} ${ product['currency'] != null
//                               ? '${product['currency']['symbol'] ?? ''}'
//                               : ''}',)
//                         ],
//                       )
//                     ],
//                   ),
//
//                 ],
//               ),
//             )),
//       ),
//     );
//   }
// }

class TitleTextInCard extends StatelessWidget {
  const TitleTextInCard({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Primary.primary,
      ),
    );
  }
}

// class FavoriteIcon extends StatefulWidget {
//   const FavoriteIcon({super.key});
//
//   @override
//   State<FavoriteIcon> createState() => _FavoriteIconState();
// }
//
// class _FavoriteIconState extends State<FavoriteIcon> {
//   bool isFav = false;
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () {
//         setState(() {
//           isFav = !isFav;
//         });
//       },
//       child: Icon(
//         Icons.favorite_border,
//         color: isFav ? Primary.primary : Colors.grey,
//         weight: 5,
//       ),
//     );
//   }
// }

// class CardDescriptionText extends StatelessWidget {
//   const CardDescriptionText({super.key, required this.text});
//   final String text;
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       textAlign: TextAlign.start,
//       style: TextStyle(color: Primary.dark, fontSize: 13),
//     );
//   }
// }

class MobileProductsPage extends StatefulWidget {
  const MobileProductsPage({super.key});

  @override
  State<MobileProductsPage> createState() => _MobileProductsPageState();
}

class _MobileProductsPageState extends State<MobileProductsPage> {
  final TextEditingController filterController = TextEditingController();
  final ScrollController scrollController=ScrollController();

  FilterItems? selectedFilterItem;
  ProductController productController = Get.find();
  List<String> categoriesNameList = ['all_categories'.tr];
  String? selectedItem = '';
  List categoriesIds = ['0'];
  String selectedCategoryId = '0';
  bool isCategoriesFetched = false;
  getCategoriesFromBack() async {
    var p = await getCategories('');
    setState(() {
      for (var item in p) {
        categoriesNameList.add('${item['category_name']}');
        categoriesIds.add('${item['id']}');
        isCategoriesFetched = true;
      }
    });
  }


  @override
  void initState() {
    productController.productsList.value = [].obs;
    productController.currentPage.value=1;
    scrollController.addListener(() {
      if(scrollController.position.pixels>=scrollController.position.maxScrollExtent && !productController.isLoading.value){
        productController.getAllProductsFromBack();
      }
    },);
    getCategoriesFromBack();
    productController.getAllProductsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(text: 'products'.tr),
              gapH10,
              ReusableButtonWithColor(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 45,
                onTapFunction: () {
                  productController.clearData();
                  productController.getFieldsForCreateProductFromBack();
                  productController.setIsItUpdateProduct(false);
                  showDialog<String>(
                    context: context,
                    builder:
                        (BuildContext context) => const AlertDialog(
                          backgroundColor: Colors.white,
                          contentPadding: EdgeInsets.all(0),
                          titlePadding: EdgeInsets.all(0),
                          actionsPadding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                          elevation: 0,
                          content: MobileCreateProductDialogContent(),
                        ),
                  );
                },
                btnText: 'create_new_product'.tr,
              ),
              gapH10,
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ReusableSearchTextField(
                      hint: '${"search".tr}...',
                      textEditingController: searchControllerInProductsPage,
                      onChangedFunc: (val) {},
                      validationFunc: (val) {},
                    ),
                  ),
                  gapW6,
                  InkWell(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                            return BarcodeScannerPage();
                          }));
                    },
                    child: Icon(Icons.barcode_reader,size: 30, color: Primary.primary),
                  ),
                ],
              ),
              gapH10,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownMenu<String>(
                    width: MediaQuery.of(context).size.width * 0.5,
                    requestFocusOnTap: false,
                    hintText: 'all_categories'.tr,
                    inputDecorationTheme: InputDecorationTheme(
                      // filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                      // outlineBorder: BorderSide(color: Colors.black,),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(9),
                        ),
                      ),
                    ),
                    // menuStyle: ,
                    dropdownMenuEntries:
                        categoriesNameList.map<DropdownMenuEntry<String>>((
                          String option,
                        ) {
                          return DropdownMenuEntry<String>(
                            value: option,
                            label: option,
                            // enabled: option.label != 'Grey',
                            // style: MenuItemButton.styleFrom(
                            // foregroundColor: color.color,
                            // ),
                          );
                        }).toList(),
                    onSelected: (String? val) {
                      setState(() {
                        selectedItem = val!;
                        var index = categoriesNameList.indexOf(val);
                        productController
                            .selectedCategoryIdInProductPage
                            .value = categoriesIds[index];
                      });
                    },
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                            productController.productsList.value = [].obs;
                          await productController.getAllProductsFromBackWithSearch();
                        },
                        child: Icon(Icons.search, color: Primary.primary),
                      ),
                      // gapW6,
                      // InkWell(
                      //   onTap:(){
                      //     Navigator.push(context, MaterialPageRoute(
                      //         builder: (BuildContext context) {
                      //           return BarcodeScannerPage();
                      //         }));
                      //   },
                      //   child: Icon(Icons.camera_alt_outlined, color: Primary.primary),
                      // ),
                      gapW6,
                      InkWell(
                        onTap: () {
                          productController.isGrid.value =
                              !productController.isGrid.value;
                        },
                        child: Icon(
                          Icons.grid_view_outlined,
                          color:
                              productController.isGrid.value
                                  ? Primary.primary
                                  : TypographyColor.textTable,
                        ),
                      ),
                      gapW6,
                      InkWell(
                        onTap: () {
                          productController.isGrid.value =
                              !productController.isGrid.value;
                        },
                        child: Icon(
                          Icons.format_list_bulleted,
                          color:
                              productController.isGrid.value
                                  ? TypographyColor.textTable
                                  : Primary.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              gapH16,
              productController.isGrid.value
                  ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child:
                        // productController.isProductsFetched.value
                        //     ?
                        GridView.count(
                          controller: scrollController,
                              crossAxisCount:
                                  1, //MediaQuery.of(context).size.width<460?1:2,
                              childAspectRatio: Sizes.deviceHeight / 450,
                              // MediaQuery.of(context).size.width<460
                              //     ? Sizes.deviceHeight / 500
                              // : Sizes.deviceHeight / 600
                              children: List.generate(
                                productController.productsList.length,
                                (index) {
                                  return _productsCard(
                                    productController.productsList[index],
                                    index,
                                  );
                                },
                              ),
                            )
                            // : const Center(child: CircularProgressIndicator()),
                  )
                  : SizedBox(
                    // height: MediaQuery.of(context).size.height * 0.4,
                    child:
                        // productController.isProductsFetched.value
                        //     ?
                        SingleChildScrollView(
                          controller: scrollController,
                              child: Row(
                                children: [
                                  Flexible(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
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
                                                  width:
                                                      150, // MediaQuery.of(context).size.width * 0.15,
                                                ),
                                                TableTitle(
                                                  text: 'name'.tr,
                                                  width:
                                                      150, // MediaQuery.of(context).size.width * 0.15,
                                                ),
                                                TableTitle(
                                                  text: 'description'.tr,
                                                  width:
                                                      350, //MediaQuery.of(context).size.width * 0.5,
                                                ),
                                                // TableTitle(
                                                //   text: 'qty_on_hand'.tr,
                                                //   width: 150//MediaQuery.of(context).size.width * 0.2,
                                                // ),
                                                TableTitle(
                                                  text: 'price'.tr,
                                                  width: 150,
                                                ),
                                                TableTitle(
                                                  text: 'currency'.tr,
                                                  width: 150,
                                                ),
                                                TableTitle(
                                                  text: 'on_hand'.tr,
                                                  width: 150,
                                                ),
                                                // TableTitle(
                                                //   text: 'qty_shipped'.tr,
                                                //   width: 150
                                                // ),
                                                const SizedBox(width: 100),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Colors.white,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                productController
                                                    .productsList
                                                    .length,
                                                (index) =>
                                                    _productsAsRowInTable(
                                                      productController
                                                          .productsList[index],
                                                      index,
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
                            )
                            // : const Center(child: CircularProgressIndicator()),
                  ),
              if(productController.isLoading.value)Padding(padding: EdgeInsets.all(16),child: Center(child: CircularProgressIndicator()),)
            ],
          ),
        ),
      ),
    );
  }

  _productsAsRowInTable(Map product, int index) {
    return InkWell(
      onDoubleTap: () {
        productController.setSelectedProductId('${product['id']}');
        productController.clearData();
        productController.getFieldsForCreateProductFromBack();
        productController.setIsItUpdateProduct(true);
        productController.setAllValuesForUpdate(product);
        showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.all(0),
              titlePadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              elevation: 0,
              content: CreateProductDialogContent(),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0)),
        ),
        child: Row(
          children: [
            TableItem(text: '${product['mainCode'] ?? ''}', width: 150),
            TableItem(text: '${product['item_name'] ?? ''}', width: 150),
            TableItem(text: '${product['mainDescription'] ?? ''}', width: 350),
            // TableItem(
            //   text:
            //       '${product['quantity'] ?? ''} ${product['packageSetName'] ?? ''}',
            //   width:  150,
            // ),
            TableItem(text: '${product['unitPrice'] ?? ''}', width: 150),
            TableItem(
              text:
                  product['priceCurrency'] != null
                      ? '${product['priceCurrency']['name'] ?? ''}'
                      : '',
              width: 150,
            ),
            TableItem(
              text:
                  '${product['current_quantity'] ?? ''} ${product['packageSetName'] ?? ''}',
              width: 150,
            ),
            // TableItem(
            //   text:
            //       '${product['current_quantity'] ?? ''} ${product['packageSetName'] ?? ''}',
            //   width:  150,
            // ),
            SizedBox(
              width: 100,
              child: ReusableMore(
                itemsList: [
                  PopupMenuItem<String>(
                    value: '1',
                    onTap: () async {
                      var res = await deleteProduct('${product['id']}');
                      var p = json.decode(res.body);
                      if (res.statusCode == 200) {
                        CommonWidgets.snackBar('Success', p['message']);
                        setState(() {
                          productController.productsList.removeAt(index);
                        });
                      } else {
                        CommonWidgets.snackBar('error', p['message']);
                      }
                    },
                    child: Text('delete'.tr),
                  ),
                  // PopupMenuItem<String>(
                  //   value: '2',
                  //   onTap: () async {
                  //     showDialog<String>(
                  //         context: context,
                  //         builder: (BuildContext context) =>
                  //             AlertDialog(
                  //                 backgroundColor:
                  //                 Colors.white,
                  //                 shape:
                  //                 const RoundedRectangleBorder(
                  //                   borderRadius:
                  //                   BorderRadius.all(
                  //                       Radius.circular(
                  //                           9)),
                  //                 ),
                  //                 elevation: 0,
                  //                 content: EditQuantityDialog(id:'${product['id']}',isMobile:true)));
                  //   },
                  //   child: Text('edit_quantity'.tr),
                  // ),
                  PopupMenuItem<String>(
                    value: '2',
                    onTap: () async {
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
                              content: EditPriceDialog(
                                product: product,
                                id: '${product['id']}',
                                isMobile: true,
                              ),
                            ),
                      );
                    },
                    child: Text('edit_price'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _productsCard(Map product, int index) {
    return InkWell(
      onDoubleTap: () {
        productController.setSelectedProductId('${product['id']}');
        productController.clearData();
        productController.getFieldsForCreateProductFromBack();
        productController.setIsItUpdateProduct(true);
        productController.setAllValuesForUpdate(product);
        showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.all(0),
              titlePadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              elevation: 0,
              content: MobileCreateProductDialogContent(),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ClipPath(
          clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Others.menuBg,
              border: Border(top: BorderSide(color: Primary.primary, width: 3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.7 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleTextInCard(text: '${product['item_name'] ?? ''}'),
                      Row(
                        children: [
                          // const FavoriteIcon(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03,
                            child: ReusableMore(
                              itemsList: [
                                PopupMenuItem<String>(
                                  value: '1',
                                  onTap: () async {
                                    var res = await deleteProduct(
                                      '${product['id']}',
                                    );
                                    var p = json.decode(res.body);
                                    if (res.statusCode == 200) {
                                      CommonWidgets.snackBar(
                                        'Success',
                                        p['message'],
                                      );
                                      setState(() {
                                        productController.productsList.removeAt(
                                          index,
                                        );
                                      });
                                    } else {
                                      CommonWidgets.snackBar(
                                        'error',
                                        p['message'],
                                      );
                                    }
                                  },
                                  child: Text('delete'.tr),
                                ),
                                // PopupMenuItem<String>(
                                //   value: '2',
                                //   onTap: () async {
                                //     showDialog<String>(
                                //         context: context,
                                //         builder: (BuildContext context) =>
                                //             AlertDialog(
                                //                 backgroundColor:
                                //                 Colors.white,
                                //                 shape:
                                //                 const RoundedRectangleBorder(
                                //                   borderRadius:
                                //                   BorderRadius.all(
                                //                       Radius.circular(
                                //                           9)),
                                //                 ),
                                //                 elevation: 0,
                                //                 content: EditQuantityDialog(id:'${product['id']}',isMobile:true)));
                                //   },
                                //   child: Text('edit_quantity'.tr),
                                // ),
                                PopupMenuItem<String>(
                                  value: '2',
                                  onTap: () async {
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
                                            content: EditPriceDialog(
                                              product: product,
                                              id: '${product['id']}',
                                              isMobile: true,
                                            ),
                                          ),
                                    );
                                  },
                                  child: Text('edit_price'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  gapH10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: Sizes.deviceWidth * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('[${product['mainCode'] ?? ''}]'),
                            SizedBox(height: Sizes.deviceHeight * 0.01),
                            Text(
                              '${'price'.tr}: ${product['unitPrice'] ?? ''} ${product['priceCurrency'] != null ? '${product['priceCurrency']['symbol'] ?? ''}' : ''}',
                            ),
                            SizedBox(height: Sizes.deviceHeight * 0.01),
                            Text(
                              '${'on_hand'.tr}: ${product['current_quantity'] ?? ''} ${product['packageUnitName'] ?? ''}',
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: '${product['images']}' == '[]'? Image.network(
                          '${product['images']}' == '[]'
                              ? 'https://theravenstyle.com/rooster-backend/public/storage/WhatsApp%20Image%202024-03-03%20at%2011.41.15%20AM.jpeg'
                              : '${product['images'][0]}',
                          height: Sizes.deviceHeight * 0.12,
                          width: Sizes.deviceWidth * 0.2,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => loading(),
                          // loadingBuilder: (context, child, loadingProgress) => loading('laod'),
                        ):Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
