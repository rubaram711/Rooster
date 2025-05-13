


import 'dart:math';

String numberWithComma(String num)
{
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  mathFunc(Match match) => '${match[1]},';
  String result = num.replaceAllMapped(reg, mathFunc);
  return result;
}



String convertListToString(List list) {
  return list.join(", ");
}

String formatDoubleWithCommas(double number) {
  // Round to two decimal places
  number = (number * 100).roundToDouble() / 100;

  String numberString = number.toString();
  List<String> parts = numberString.split('.'); // Split integer and decimal parts
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? '.${parts[1]}' : '.00'; // Ensure two decimal places

  String formattedInteger = '';
  int count = 0;

  for (int i = integerPart.length - 1; i >= 0; i--) {
    formattedInteger = integerPart[i] + formattedInteger;
    count++;
    if (count % 3 == 0 && i != 0) {
      formattedInteger = ',$formattedInteger';
    }
  }

  return formattedInteger + decimalPart;
}



String formatPackagingInfo(Map<String, dynamic> packagingMap) {
  List<String> result = [];

  if (packagingMap['containerQty'] != 0 && packagingMap['containerName'] != null) {
    result.add('${packagingMap['containerQty']} ${packagingMap['containerName']}');
  }
  if (packagingMap['paletteQty'] != 0 && packagingMap['paletteName'] != null) {
    result.add('${packagingMap['paletteQty']} ${packagingMap['paletteName']}');
  }
  if (packagingMap['supersetQty'] != 0 && packagingMap['supersetName'] != null) {
    result.add('${packagingMap['supersetQty']} ${packagingMap['supersetName']}');
  }
  if (packagingMap['setQty'] != 0 && packagingMap['setName'] != null) {
    result.add('${packagingMap['setQty']} ${packagingMap['setName']}');
  }
  if (packagingMap['unitQty'] != 0 && packagingMap['unitName'] != null) {
    result.add('${packagingMap['unitQty']} ${packagingMap['unitName']}');
  }

  return result.join(', ');
}



List<List<T>> splitList<T>(List<T> list, int chunkSize) {
  List<List<T>> chunks = [];
  int len = list.length;
  for (int i = 0; i < len; i += chunkSize) {
    int end = (i + chunkSize < len) ? i + chunkSize : len;
    chunks.add(list.sublist(i, end));
  }
  return chunks;
}



double roundUp(double value, int decimalPlaces) {
  final factor = pow(10, decimalPlaces);
  return (value * factor).ceil() / factor;
}


String calculateRateCur1ToCur2(double usdToCur1, double usdToCur2) {
  if (usdToCur1 == 0) {
    throw ArgumentError("USD to CUR1 rate cannot be zero.");
  }
  double result =roundUp((usdToCur2 / usdToCur1),3);
  return (result).toString();
}



//
// Future<Uint8List> fetchImage(String url) async {
//   try {
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       throw Exception(
//         "Failed to load image. Status code: ${response.statusCode}",
//       );
//     }
//   } catch (e) {
//     // Handle the error or show a fallback image
//     throw Exception("Failed to fetch image: $e");
//   }
// }


