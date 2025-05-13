import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../const/urls.dart';


Future getCountries() async {
  final uri = Uri.parse(kGetCountriesUrl);
  var response = await http.get(
    uri,
  );

  var p = json.decode(response.body);
  if(response.statusCode==200) {
    return p['data'];
  }else {
    return [];
  }
}

