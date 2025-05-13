import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../const/urls.dart';

Future getCitiesOfASpecifiedCountry(
    String country
    ) async {
  final uri = Uri.parse(kGetCitiesOfASpecifiedCountryUrl);
  var response = await http.post(uri, body: {
    "country": country
  });

  var p = json.decode(response.body);
  if(p['error']==false) {
    return p['data'];
  }else {
    return [];
  }
}
