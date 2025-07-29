import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/const/sizes.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/products_controller.dart';
import '../../Screens/Combo/combo.dart';
import '../../Screens/Products/CreateProductDialog/create_product_dialog.dart';
import '../../const/colors.dart';
// import 'dart:html' as html;


class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return
      // SizedBox(
      // width: MediaQuery.of(context).size.width * 0.21,
      // child: Stack(
      //   children: [
          Drawer(
            // width:  MediaQuery.of(context).size.width * 0.2,
            backgroundColor: Primary.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // InkWell(
                  //   onTap:(){
                  //     // homeController.selectedTab.value ='dashboard_summary';
                  //   },
                  //   child: SvgPicture.asset(
                  //     'assets/images/RoosterLogoDraft.svg',
                  //     height: MediaQuery.of(context).size.height * 0.2,
                  //     // height: MediaQuery.of(context).size.height*0.3,
                  //   ),
                  // ),
                  Container(
                    // width: 20,
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/rooster.jpeg'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  gapH20,
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (BuildContext context, int index) =>
                          EntryItem(data[index],idDesktop: false),
                      itemCount: data.length,
                    ),
                  ),
                ],
              ),
          )
          // Positioned(
          //     right: 1,
          //     top: 20,
          //     child: InkWell(
          //       onTap: () {},
          //       child: CircleAvatar(
          //         radius: 18,
          //         backgroundColor: Colors.white,
          //         child: Icon(
          //           Icons.keyboard_arrow_left,
          //           color: Primary.primary,
          //         ),
          //       ),
          //     )),
    //     ],
    //   ),
    // )
    ;
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  const Entry(this.title, this.icon, [this.children = const <Entry>[]]);
  final String title;
  final String icon;
  final List<Entry> children;
}

// Data to display.
const List<Entry> data = <Entry>[
  Entry(
    'sales_and_clients',
    "assets/images/clientsIcon.png",
    <Entry>[
      Entry(
        'clients',
        '',
        // "assets/images/clientsIcon.png",
        <Entry>[
          Entry('accounts', ''),
          Entry("add_new_client", ''),
        ],
      ),
      Entry(
        'quotation',
        '',
        //"assets/images/quotationIcon.png",
        <Entry>[
          Entry('new_quotation', ''),
          Entry('quotation_summary', ''),
        ],
      ),
      Entry(
        'sales_order',
        '',
        //"assets/images/clientOrderIcon.png",
        <Entry>[
          Entry(
            'new_sales_order',
            "",
          ),
          Entry(
            'sales_order_summary',
            "",
          ),
        ],
      ),
      Entry(
        'sales_invoice',
        '',
        //"assets/images/salesInvoiceIcon.png",
        <Entry>[
          Entry(
            'new_sales_invoice',
            "",
          ),
          Entry(
            'sales_invoice_summary',
            "",
          ),
        ],
      ),
      Entry(
        'return_from_client',
        '',
        // "assets/images/returnfromclient.png",
        <Entry>[
          Entry(
            'return_from_client',
            "",
          ),
          Entry(
            'return_from_client_summary',
            "",
          ),
        ],
      ),
      Entry(
        'delivery',
        "",
        <Entry>[
          Entry(
            'new_delivery',
            "",
          ),
          Entry(
            'deliveries_summary',
            "",
          ),
        ]
      ),
      Entry(
        'pending_docs',
        "",
        <Entry>[
          Entry('pending_quotation', ""),
          Entry(
            'to_sales_order',
            "",
          ),
          Entry(
            'to_invoice',
            "",
          ),
          Entry(
            'to_deliver',
            "",
          ),
        ]
      ),
    ],
  ),
  Entry(
    'purchases_and_suppliers',
    "assets/images/suppliers.png",
    <Entry>[
      Entry(
        'suppliers',
        '',
        //"assets/images/suppliers.png",
        <Entry>[
          Entry(
            'suppliers',
            "",
          ),
        ],
      ),
      Entry(
        'supplier_order',
        '',
        //"assets/images/supplierOrderIcon.png",
        <Entry>[
          Entry(
            'new_supplier_order',
            "",
          ),
          Entry(
            'supplier_order_summary',
            "",
          ),
        ],
      ),
      Entry(
        'purchase_invoice',
        '',
        //"assets/images/purchaseInvoiceIcon.png",
        <Entry>[
          Entry(
            'new_purchase_invoice',
            "",
          ),
          Entry(
            'purchase_invoice_summary',
            "",
          ),
        ],
      ),
      Entry(
        'return_to_supplier',
        '',
        //"assets/images/returntosupplier.png",
        <Entry>[
          Entry(
            'return_to_supplier',
            "",
          ),
          Entry(
            'return_to_supplier_summary',
            "",
          ),
        ],
      ),
    ],
  ),
  Entry(
    'inventory_management',
    "assets/images/inventoryIcon.png",
    <Entry>[
      Entry(
          'warehouses',
          '',
          <Entry>[
        Entry('warehouses', ''),
        Entry('create_warehouse', ''),
      ]),
      Entry(
          "transfers",
          '',
          //"assets/images/transfer.png",
          <Entry>[
            Entry('transfers', ''),
            Entry('transfer_out', ''),
          ]
      ),
      Entry(
          "replenishment",
          '',
          //"assets/images/transfer.png",
          <Entry>[
            Entry('replenishment', ''),
            Entry('replenish_transfer', '')
          ]
      ),
      Entry(
        'physical_inventory',
        "",
      ),
      Entry(
        'counting_form',
        "",
      ),
    ],
  ),
  // Entry(
  //   'quotation',
  //   "assets/images/quotationIcon.png",
  //   <Entry>[
  //     Entry('new_quotation', ''),
  //     Entry('quotation_summary', ''),
  //   ],
  // ),
  // Entry(
  //   'clients',
  //   "assets/images/clientsIcon.png",
  //   <Entry>[
  //     Entry('accounts', ''),
  //     Entry("add_new_client", ''),
  //   ],
  // ),
  Entry(
    'stock',
    "assets/images/stockIcon.png",
    <Entry>[
      Entry('items', ''),
      Entry('combo', '',<Entry>[
        Entry('create_combo', ''),
        Entry('combo_summary', ''),
      ]),

      // Entry('create_items', ''),
      // Entry(
      //   'inventory',
      //   '',
      //   // "assets/images/inventoryIcon.png",
      //   <Entry>[
      //     Entry(
      //       'physical_inventory',
      //       "",
      //     ),
      //     Entry(
      //       'counting_form',
      //       "",
      //     ),
      //   ],
      // ),
      // Entry("combos", ''),
      // Entry('brands', ''),
    ],
  ),
  // Entry(
  //   "categories",
  //   "assets/images/categoriesIcon.png",
  //     <Entry>[Entry('categories', ''), Entry('create_category', '')]),
  Entry(
    "poss",
    "assets/images/pos.png",
      <Entry>[Entry('poss', '')]
  ),
  // Entry(
  //   "transfers",
  //   "assets/images/transfer.png",
  //     <Entry>[
  //       Entry('transfers', ''),
  //       Entry('transfer_out', ''),
  //       Entry('replenishment', ''),
  //       Entry('replenish_transfer', '')]
  // ),
  // Entry(
  //   'reports',
  //   "assets/images/reportsIcon.png",
  //   <Entry>[
  //     Entry('reports1', ''),
  //     Entry("reports2", ''),
  //     Entry("reports3", ''),
  //   ],
  // ),
  Entry(
    'dashboard_summary',
    "assets/images/dashboardIcon.png",
      <Entry>[
        Entry('dashboard_summary', ''),
        ]
  ),
  // Entry(
  //   'admin_panel',
  //   "assets/images/adminPanelIcon.png",
  //   <Entry>[
  //     Entry('lorem_ipsum', ''),
  //     Entry('lorem_ipsum', ''),
  //     Entry("lorem_ipsum", ''),
  //   ],
  // ),

  Entry(
    'account_settings',
    "assets/images/settingsIcon.png",
    <Entry>[
      Entry(
        'users',
        "",
        <Entry>[
          // Entry('create_users', ''),
          Entry('users', ''),
          Entry('roles', ''),
          Entry('pos', ''),
          Entry('back-office', ''),
        ],
      ),
      // Entry(
      //   'permissions',
      //   "",
      //   <Entry>[
      //     Entry('roles_groups', ''),
      //     Entry('permissions', ''),
      //   ],
      // ),
      // Entry('category_security_level', ''),
      // Entry("paper_template", ''),
      // Entry("domination_name", ''),
    ],
  ),
  Entry(
    'pos_reports',
    "assets/images/clientOrderIcon.png",
    <Entry>[
      Entry(
        'sessions_details',
        "",
      ),
      Entry(
        'daily_qty_report',
        "",
      ),
      Entry(
        'cash_tray_report',
        "",
      ),
    ],
  ),
  // Entry(
  //   'suppliers',
  //   "assets/images/suppliers.png",
  //   <Entry>[
  //     Entry(
  //       'suppliers',
  //       "",
  //     ),
  //   ],
  // ),
  // Entry(
  //   'client_order',
  //   "assets/images/clientOrderIcon.png",
  //   <Entry>[
  //     Entry(
  //       'new_client_order',
  //       "",
  //     ),
  //     Entry(
  //       'client_order_summary',
  //       "",
  //     ),
  //   ],
  // ),
  // Entry(
  //   'sales_invoice',
  //   "assets/images/salesInvoiceIcon.png",
  //   <Entry>[
  //     Entry(
  //       'new_sales_invoice',
  //       "",
  //     ),
  //     Entry(
  //       'sales_invoice_summary',
  //       "",
  //     ),
  //   ],
  // ),
  // Entry(
  //   'supplier_order',
  //   "assets/images/supplierOrderIcon.png",
  //   <Entry>[
  //     Entry(
  //       'new_supplier_order',
  //       "",
  //     ),
  //     Entry(
  //       'supplier_order_summary',
  //       "",
  //     ),
  //   ],
  // ),
  // Entry(
  //   'purchase_invoice',
  //   "assets/images/purchaseInvoiceIcon.png",
  //   <Entry>[
  //     Entry(
  //       'new_purchase_invoice',
  //       "",
  //     ),
  //     Entry(
  //       'purchase_invoice_summary',
  //       "",
  //     ),
  //   ],
  // ),
  // Entry(
  //   'return_from_client',
  //   "assets/images/returnfromclient.png",
  //   <Entry>[
  //     Entry(
  //       'return_from_client',
  //       "",
  //     ),
  //     Entry(
  //       'return_from_client_summary',
  //       "",
  //     ),
  //   ],
  // ),
  // Entry(
  //   'return_to_supplier',
  //   "assets/images/returntosupplier.png",
  //   <Entry>[
  //     Entry(
  //       'return_to_supplier',
  //       "",
  //     ),
  //     Entry(
  //       'return_to_supplier_summary',
  //       "",
  //     ),
  //   ],
  // ),

];

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatefulWidget {
  const EntryItem(this.entry, {super.key, required this.idDesktop});
final bool idDesktop;
  final Entry entry;

  @override
  State<EntryItem> createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  Widget _buildTiles(Entry root) {
    final HomeController homeController = Get.find();
    final ProductController productController = Get.find();
    if (root.title == 'dashboard_summary') {
      return ListTile(
          leading: Container(
            width: 20,
            height: 22,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(root.icon),
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Text(
            root.title.tr,
            style: TextStyle(
                // fontSize: 15,
                color: TypographyColor.searchBar,
                fontWeight: FontWeight.bold),
          ));
    } else if (root.children.isEmpty) {
      return ListTile(
          onTap: () {
            if(root.title=='create_items'){
              productController.clearData();
              productController.getFieldsForCreateProductFromBack();
              productController.setIsItUpdateProduct(false);
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      backgroundColor: Colors.white,
                      contentPadding: const EdgeInsets.all(0),
                      titlePadding: const EdgeInsets.all(0),
                      actionsPadding: const EdgeInsets.all(0),
                      shape:const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),) ,
                      elevation: 0,
                      content:widget.idDesktop? const CreateProductDialogContent(): const MobileCreateProductDialogContent(),
                    ));

            } else if (root.title == 'create_combo') {
              showDialog<String>(
                context: context,
                builder:
                    (BuildContext context) => AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding: const EdgeInsets.all(0),
                  titlePadding: const EdgeInsets.all(0),
                  actionsPadding: const EdgeInsets.all(0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                  elevation: 0,
                  content:
                  widget.idDesktop
                      ? const Combo()
                      : const MobileCreateProductDialogContent(),
                ),
              );
            }
            // else if(root.title=='create_category'){
            //     showDialog<String>(
            //         context: context,
            //         builder: (BuildContext context) => const AlertDialog(
            //           backgroundColor: Colors.white,
            //           contentPadding: EdgeInsets.all(0),
            //           titlePadding: EdgeInsets.all(0),
            //           actionsPadding: EdgeInsets.all(0),
            //           shape:RoundedRectangleBorder(
            //             borderRadius: BorderRadius.all(Radius.circular(9)),) ,
            //           elevation: 0,
            //           content:CreateCategoryDialogContent(),
            //           // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
            //         ));
            //
            // }
            else{
            homeController.selectedTab.value = root.title;}
          },
          title: Row(
            children: [
              gapW32,
              SizedBox(
                //todo
                // width: MediaQuery.of(context).size.width * 0.08,
                child: Text(
                  overflow: TextOverflow.clip,
                  root.title.tr,
                  style:
                      TextStyle(fontSize: 12, color: TypographyColor.searchBar),
                ),
              ),
            ],
          ));
    }
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: InkWell(
        onTap: () {
          homeController.selectedTab.value = root.title;
        },
        child: Text(
          root.title.tr,
          style: TextStyle(
              // fontSize: 15,
              fontWeight: FontWeight.bold,
              color: TypographyColor.searchBar),
        ),
      ),
      leading:root.icon==''
          ? const SizedBox(width: 18, height: 20,)
          : Container(
        width: 18,
        height: 20,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(root.icon),
            fit: BoxFit.contain,
          ),
        ),
      ),
      iconColor: TypographyColor.searchBar,
      collapsedIconColor: TypographyColor.searchBar,
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.entry);
  }
}

// class ClosedSidebarItem extends StatelessWidget {
//   const ClosedSidebarItem(this.entry,
//       {super.key, required this.onHoverFunc, required this.context});
//
//   final Entry entry;
//   final Function onHoverFunc;
//   final BuildContext context;
//   Widget _buildTiles(Entry root) {
//     final HomeController homeController = Get.find();
//     GlobalKey accKey = GlobalKey();
//     if (root.title != 'dashboard_summary' || root.children.isNotEmpty) {
//       return InkWell(
//         key: accKey,
//         onHover: (val) {
//           if (val) {
//             final RenderBox renderBox =
//                 accKey.currentContext?.findRenderObject() as RenderBox;
//             final Size size = renderBox.size;
//             final Offset offset = renderBox.localToGlobal(Offset.zero);
//             showMenu(
//               context: context,
//               // color: Primary.primary,
//               shadowColor: Colors.black45,
//               shape: const RoundedRectangleBorder(
//                 side: BorderSide(color: Colors.black26),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(00.0),
//                 ),
//               ),
//               position: RelativeRect.fromLTRB(
//                   offset.dx + size.width + 10,
//                   offset.dy + size.height - 30,
//                   offset.dx + size.width + 50,
//                   offset.dy + size.height),
//               items: root.children
//                   .map((item) => PopupMenuItem<String>(
//                         value: item.title.tr,
//                         onTap: () {
//                           homeController.selectedTab.value = item.title;
//                         },
//                         child: Text(
//                           item.title.tr,
//                         ),
//                       ))
//                   .toList(),
//             );
//           }
//           if(!val){
//             // Get.back();
//           }
//         },
//         onTap: () {
//           // if (val == true) {
//           final RenderBox renderBox =
//               accKey.currentContext?.findRenderObject() as RenderBox;
//           final Size size = renderBox.size;
//           final Offset offset = renderBox.localToGlobal(Offset.zero);
//           showMenu(
//             context: context,
//             // color: Primary.primary,
//             shadowColor: Colors.black45,
//             shape: const RoundedRectangleBorder(
//               side: BorderSide(color: Colors.black26),
//               borderRadius: BorderRadius.all(
//                 Radius.circular(00.0),
//               ),
//             ),
//             position: RelativeRect.fromLTRB(
//                 offset.dx + size.width + 10,
//                 offset.dy + size.height - 30,
//                 offset.dx + size.width + 50,
//                 offset.dy + size.height),
//             items: root.children
//                 .map((item) => PopupMenuItem<String>(
//                       value: item.title.tr,
//                       child: Text(
//                         item.title.tr,
//                       ),
//                     ))
//                 .toList(),
//           );
//         },
//         child: Container(
//           width: 18,
//           height: 20,
//           margin: const EdgeInsets.symmetric(vertical: 15),
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(root.icon),
//               fit: BoxFit.contain,
//             ),
//           ),
//         ),
//       );
//     }
//     return InkWell(
//       onTap: (){
//         homeController.selectedTab.value = root.title;
//       },
//       child: Container(
//         width: 18,
//         height: 20,
//         margin: const EdgeInsets.symmetric(vertical: 15),
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(root.icon),
//             fit: BoxFit.contain,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _buildTiles(entry);
//   }
// }

// class ClosedSidebar extends StatefulWidget {
//   const ClosedSidebar({super.key});
//
//   @override
//   State<ClosedSidebar> createState() => _ClosedSidebarState();
// }
//
// class _ClosedSidebarState extends State<ClosedSidebar> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width * 0.045,
//       child: Stack(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width * 0.035,
//             // height: 200,
//             color: Primary.primary,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 gapH70,
//                 Expanded(
//                   child: ListView.builder(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//                     itemBuilder: (BuildContext context, int index) =>
//                         ClosedSidebarItem(
//                       data[index],
//                       context: context,
//                       onHoverFunc: () {
//                         // showPopupMenu(context);
//                       },
//                     ),
//                     itemCount: data.length,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//               right: 1,
//               top: 20,
//               child: InkWell(
//                 onTap: () {
//                   // _controller.forward();
//                 },
//                 child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.keyboard_arrow_right,
//                     color: Primary.primary,
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }

// class CustomPopUpMenu extends StatelessWidget {
//   const CustomPopUpMenu({super.key, required this.items});
//   final List items;
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton(
//       itemBuilder: (context) => items
//           .map((item) => PopupMenuItem<String>(
//                 value: item.code.tr,
//                 child: Text(
//                   item.code.tr,
//                 ),
//               ))
//           .toList(),
//       onSelected: (String value) {},
//     );
//   }
// }

showPopupMenu(context) {
  showMenu<String>(
    context: context,
    position: const RelativeRect.fromLTRB(25.0, 25.0, 0.0,
        0.0), //position where you want to show the menu on screen
    items: [
      const PopupMenuItem<String>(value: '1', child: Text('menu option 1')),
      const PopupMenuItem<String>(value: '2', child: Text('menu option 2')),
      const PopupMenuItem<String>(value: '3', child: Text('menu option 3')),
    ],
    elevation: 8.0,
  );
  //     .then<void>((String itemSelected) {
  //
  //   if (itemSelected == null) return;
  //
  //   if(itemSelected == "1"){
  //     //code here
  //   }else if(itemSelected == "2"){
  //     //code here
  //   }else{
  //     //code here
  //   }
  //
  // });
}

// class SideBar extends StatefulWidget {
//   const SideBar({super.key, required this.animationController});
//   final AnimationController animationController;
//   @override
//   State<SideBar> createState() => _SideBarState();
// }
//
// class _SideBarState extends State<SideBar> {
//   late Animation<double> widthAnimation;
//   @override
//   void initState() {
//     // widthAnimation = Tween<double>(
//     //   begin: MediaQuery.of(context).size.width * 0.045,
//     //   end: MediaQuery.of(context).size.width * 0.21,
//     // ).animate(widget.animationController);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widthAnimation.value,
//       child: Stack(
//         children: [
//           (widthAnimation.value >= MediaQuery.of(context).size.width * 0.21)
//               ? Container(
//                   width: MediaQuery.of(context).size.width * 0.19,
//                   // height: 200,
//                   color: Primary.primary,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       InkWell(
//                         onTap:(){
//                           // homeController.selectedTab.value ='dashboard_summary';
//                         },
//                         child: SvgPicture.asset(
//                           'assets/images/RoosterLogoDraft.svg',
//                           width: MediaQuery.of(context).size.width * 0.19,
//                           // height: MediaQuery.of(context).size.height*0.3,
//                         ),
//                       ),
//                       gapH20,
//                       Expanded(
//                         child: ListView.builder(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           itemBuilder: (BuildContext context, int index) =>
//                               EntryItem(data[index],idDesktop: true),
//                           itemCount: data.length,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : Container(
//                   width: MediaQuery.of(context).size.width * 0.035,
//                   // height: 200,
//                   color: Primary.primary,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       gapH70,
//                       Expanded(
//                         child: ListView.builder(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 5, vertical: 10),
//                           itemBuilder: (BuildContext context, int index) =>
//                               ClosedSidebarItem(
//                             data[index],
//                             context: context,
//                             onHoverFunc: () {
//                               // showPopupMenu(context);
//                             },
//                           ),
//                           itemCount: data.length,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//           // (widthAnimation.value >= MediaQuery.of(context).size.width * 0.21)
//           //     ?
//           Positioned(
//               right: 0.8,
//               top: 30,
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     widthAnimation = Tween<double>(
//                       begin: MediaQuery.of(context).size.width * 0.21,
//                       end: MediaQuery.of(context).size.width * 0.045,
//                     ).animate(widget.animationController);
//                   });
//                 },
//                 child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: Colors.white,
//                   child: (widthAnimation.value >=
//                           MediaQuery.of(context).size.width * 0.21)
//                       ? Icon(
//                           Icons.keyboard_arrow_left,
//                           color: Primary.primary,
//                         )
//                       : Icon(
//                           Icons.keyboard_arrow_right,
//                           color: Primary.primary,
//                         ),
//                 ),
//               ))
//           // : Positioned(
//           //     right: 1,
//           //     top: 20,
//           //     child: InkWell(
//           //       onTap: () {
//           //         // _controller.forward();
//           //         setState(() {
//           //           widthAnimation = Tween<double>(
//           //             begin: MediaQuery.of(context).size.width * 0.045,
//           //             end: MediaQuery.of(context).size.width * 0.21,
//           //           ).animate(widget.animationController);
//           //         });
//           //       },
//           //       child: CircleAvatar(
//           //         radius: 18,
//           //         backgroundColor: TypographyColor.searchBar,
//           //         child: Icon(
//           //           Icons.keyboard_arrow_right,
//           //           color: Primary.primary,
//           //         ),
//           //       ),
//           //     )),
//         ],
//       ),
//     );
//   }
// }

class SideBarBasic extends StatefulWidget {
  const SideBarBasic({
    super.key,
    required this.minWidth,
    required this.maxWidth,
  });
  final double minWidth;
  final double maxWidth;

  @override
  State<SideBarBasic> createState() => _SideBarBasicState();
}

class _SideBarBasicState extends State<SideBarBasic>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.find();
  // late AnimationController _animationController;
  // late Animation<double> widthAnimation;
  bool isCollapsed = false;

  // OverlayEntry? mainMenuOverlay;
  // OverlayEntry? subMenuOverlay;
  void showMainMenu(BuildContext context, Offset offset, List<Entry> menuItems) {
    homeController.mainMenuOverlay?.remove();
    homeController.subMenuOverlay?.remove(); // Clear any existing sub-menus

    homeController.mainMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy,
        left: offset.dx+10,
        child: Material(
          elevation: 4.0,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 200,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: menuItems.map((item) {
                  return MouseRegion(
                    onEnter: (event) {
                      if (item.children.isNotEmpty) {
                        showSubMenu(context, item.children, offset + const Offset(210, 0));
                      }
                    },
                    child: ListTile(
                      title: Text(item.title.tr),
                      onTap: () {
                        if (item.children.isEmpty) {
                          homeController.selectedTab.value = item.title;
                          homeController.hideMenus();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(homeController.mainMenuOverlay!);
  }

  void showSubMenu(BuildContext context, List<Entry> subMenuItems, Offset offset) {
    homeController.subMenuOverlay?.remove();

    homeController.subMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy,
        left: offset.dx,
        child: Material(
          elevation: 4.0,
          child: GestureDetector(
            onTap: () {}, // Prevent taps inside the menu from closing it
            child: Container(
              width: 200,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: subMenuItems.map((item) {
                  return MouseRegion(
                    onEnter: (event) {
                      if (item.children.isNotEmpty) {
                        showSubMenu(context, item.children, offset + const Offset(200, 0));
                      }
                    },
                    child: ListTile(
                      title: Text(item.title.tr),
                      onTap: () {
                        if (item.children.isEmpty) {
                          homeController.selectedTab.value = item.title;
                          homeController.hideMenus();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(homeController.subMenuOverlay!);
  }



  @override
  void dispose() {
    homeController.hideMenus();
    super.dispose();
  }



  @override
  void initState() {
    // homeController.animationController = AnimationController(
    //     vsync: this, duration: const Duration(milliseconds: 40));
    // homeController.widthAnimation = Tween<double>(begin: widget.maxWidth, end: widget.minWidth)
    //     .animate(CurvedAnimation(parent:  homeController.animationController, curve: Curves.linear));
    // if(homeController.isOpened.value){
    // homeController.widthAnimation = Tween<double>(begin: widget.maxWidth, end: widget.minWidth)
    //     .animate(CurvedAnimation(parent:  homeController.animationController, curve: Curves.linear));
    // }else{
    //   homeController.widthAnimation = Tween<double>(begin: widget.minWidth, end: widget.maxWidth)
    //       .animate(CurvedAnimation(parent:  homeController.animationController, curve: Curves.linear));
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return AnimatedBuilder(
    //   animation:  homeController.animationController,
    //   builder: (context, child) {
        return SizedBox(
          // width: homeController.widthAnimation.value,
          width: isCollapsed?widget.minWidth:widget.maxWidth,
          child:Obx(() =>  Stack(
            children: [
              // ( homeController.widthAnimation.value < widget.maxWidth)
              !homeController.isOpened.value
                  ? Container(
                width:   isCollapsed?widget.minWidth-15:widget.maxWidth-15,//MediaQuery.of(context).size.width * 0.035,
                // height: 200,
                color: Primary.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    gapH70,
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.map((entry) {
                          return MouseRegion(
                            onEnter: (event) {
                              final overlayPosition = event.position; // Get hover position
                              showMainMenu(context, overlayPosition, entry.children);
                            },
                            child:  Container(
                              width: 18,
                              height: 20,
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(entry.icon),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }).toList(),),
                      // child: ListView.builder(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 5, vertical: 10),
                      //   itemBuilder: (BuildContext context, int index) =>
                      //       ClosedSidebarItem(
                      //     data[index],
                      //     context: context,
                      //     onHoverFunc: () {
                      //       // showPopupMenu(context);
                      //     },
                      //   ),
                      //   itemCount: data.length,
                      // ),
                    ),
                  ],
                ),
              )
                  : Container(
                width: isCollapsed?widget.minWidth-15:widget.maxWidth-15,// MediaQuery.of(context).size.width * 0.2,
                // height: 200,
                color: Primary.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // InkWell(
                    //   onTap:(){
                    //     homeController.selectedTab.value ='dashboard_summary';
                    //   },
                    //   child: SvgPicture.asset(
                    //     'assets/images/RoosterLogoDraft.svg',
                    //     width: isCollapsed?widget.minWidth-15:widget.maxWidth-15,
                    //     // height: MediaQuery.of(context).size.height*0.3,
                    //   ),
                    // ),
                    Container(
                      width: isCollapsed?widget.minWidth-15:widget.maxWidth-15,
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/rooster.jpeg'),
                          // fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    gapH20,
                    Expanded(
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (BuildContext context, int index) =>
                            EntryItem(data[index],idDesktop: true),
                        itemCount: data.length,
                      ),
                    ),
                  ],
                ),
              ),
              // ( widthAnimation.value<widget.maxWidth)
              //     ?
              Positioned(
                // right: 1,
                  left: isCollapsed?widget.minWidth - 35:widget.maxWidth-35,
                  top: 20,
                  child: InkWell(
                    onTap: () async{
                      // html.window.location.reload();
                      // await saveTabLocally(homeController.selectedTab.value);
                      // await saveIsOpenedLocally(!homeController.isOpened.value);
                      setState(() {
                        isCollapsed = !isCollapsed;
                        homeController.isOpened.value =
                        !homeController.isOpened.value;
                        // isCollapsed
                        //     ?  homeController.forwardController()
                        //     :  homeController.reverseController();
                        // homeController.setRelativeWidth(
                        //     MediaQuery.of(context).size.width -homeController.widthAnimation.value
                        // );
                        // homeController.selectedTab.value =homeController.selectedTab.value;
                      });

                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: TypographyColor.searchBar,
                      // child: ( homeController.widthAnimation.value >=
                      //     MediaQuery.of(context).size.width * 0.21)
                    child:  !isCollapsed
                          ? Icon(
                        Icons.keyboard_arrow_left,
                        color: Primary.primary,
                      )
                          : Icon(

                        Icons.keyboard_arrow_right,
                        color: Primary.primary,
                      ),
                    ),
                  ))
              // :Positioned(
              //     right: 1,
              //     top: 20,
              //     child: InkWell(
              //       onTap: () {
              //         setState(() {
              //           isCollapsed=!isCollapsed;
              //           homeController.isOpened.value=!homeController.isOpened.value;
              //           isCollapsed?_animationController.forward():_animationController.reverse();
              //         });
              //       },
              //       child: CircleAvatar(
              //         radius: 18,
              //         backgroundColor: Colors.white,
              //         child: Icon(
              //           Icons.keyboard_arrow_left,
              //           color: Primary.primary,
              //         ),
              //       ),
              //     )),
            ],
          ),),
        );
    //   },
    // );
  }
}
