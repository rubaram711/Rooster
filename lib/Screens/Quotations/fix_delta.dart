import 'dart:convert';


String fixQuillHeaderDelta(String jsonDelta) {
  final List<dynamic> ops = jsonDecode(jsonDelta);
  final List<Map<String, dynamic>> fixedOps = [];

  for (int i = 0; i < ops.length; i++) {
    final current = Map<String, dynamic>.from(ops[i]);

    if (current['insert'] == '\n' && current['attributes']?.containsKey('header') == true) {
      if (fixedOps.isNotEmpty) {
        final prev = Map<String, dynamic>.from(fixedOps.removeLast());
        final prevAttrs = Map<String, dynamic>.from(prev['attributes'] ?? {});
        prevAttrs['header'] = current['attributes']['header'];
        prev['attributes'] = prevAttrs;
        fixedOps.add(prev);
      }

      fixedOps.add({'insert': '\n'});
    } else {
      fixedOps.add(current);
    }
  }

  return jsonEncode(fixedOps);
}
