import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../Controllers/products_controller.dart';
import 'products_page.dart';


class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String _barcode = 'Scan a barcode';  // Initial placeholder text
  ProductController productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.camera_alt),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) async {
                // Extract barcode value from the BarcodeCapture object
                final String code = barcodeCapture.barcodes.first.rawValue ?? 'Unknown';

                // Update the barcode value and stop scanning
                setState(() {
                  _barcode = code;
                  searchControllerInProductsPage.text=_barcode;// Display the scanned barcode value
                });
                productController.isLoading.value = true;
                await productController.getAllProductsFromBack();
                Get.back();
              },
            ),
          )
        ],
      ),
    );
  }
}



