import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'fix_delta.dart';

pw.Widget quillDeltaToPdfWidget(String jsonDelta) {
  jsonDelta = fixQuillHeaderDelta(jsonDelta);
  final ops = jsonDecode(jsonDelta) as List<dynamic>;

  final List<pw.Widget> widgets = [];
  List<pw.InlineSpan> currentLineSpans = [];
  int? currentHeaderLevel;
  Map<String, dynamic>? lastAttrs;

  for (final op in ops) {
    final map = Map<String, dynamic>.from(op);
    final text = map['insert'] as String;
    final attrs = Map<String, dynamic>.from(map['attributes'] ?? {});
    lastAttrs = attrs;

    final style = pw.TextStyle(
      fontWeight: attrs['header'] != null
          ? pw.FontWeight.bold
          : attrs['bold'] == true
          ? pw.FontWeight.bold
          : pw.FontWeight.normal,
      fontStyle: attrs['italic'] == true ? pw.FontStyle.italic : pw.FontStyle.normal,
      decoration: attrs['underline'] == true ? pw.TextDecoration.underline : pw.TextDecoration.none,
      fontSize: attrs['header'] != null
          ? attrs['header'] == 1
          ? 24
          : attrs['header'] == 2
          ? 20
          : attrs['header'] == 3
          ? 18
          : 12
          : _getFontSize(attrs['size']),
    );

    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.isNotEmpty) {
        currentLineSpans.add(pw.TextSpan(text: line, style: style));
        if (attrs.containsKey('header')) {
          currentHeaderLevel = attrs['header'];
        }
      }

      final isLast = i == lines.length - 1;
      if (!isLast) {
        final lineWidget = pw.RichText(
          text: pw.TextSpan(children: currentLineSpans),
        );

        if (attrs.containsKey('list')) {
          final isBullet = attrs['list'] == 'bullet';
          widgets.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(isBullet ? '• ' : '1. ', style: pw.TextStyle(fontSize: 12)),
                pw.Expanded(child: lineWidget),
              ],
            ),
          );
        } else if (currentHeaderLevel != null) {
          widgets.add(
            pw.DefaultTextStyle(
              style: pw.TextStyle(fontSize: _getHeaderFontSize(currentHeaderLevel)),
              child: lineWidget,
            ),
          );
          currentHeaderLevel = null;
        } else {
          widgets.add(lineWidget);
        }

        currentLineSpans = [];
      }
    }
  }

  // آخر سطر
  if (currentLineSpans.isNotEmpty) {
    final lineWidget = pw.RichText(
      text: pw.TextSpan(children: currentLineSpans),
    );

    if (lastAttrs != null && lastAttrs.containsKey('list')) {
      final isBullet = lastAttrs['list'] == 'bullet';
      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(isBullet ? '• ' : '1. ', style: pw.TextStyle(fontSize: 12)),
            pw.Expanded(child: lineWidget),
          ],
        ),
      );
    } else if (currentHeaderLevel != null) {
      widgets.add(
        pw.DefaultTextStyle(
          style: pw.TextStyle(fontSize: _getHeaderFontSize(currentHeaderLevel)),
          child: lineWidget,
        ),
      );
    } else {
      widgets.add(lineWidget);
    }
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: widgets,
  );
}

double _getFontSize(dynamic size) {
  if (size == null) return 12;
  if (size is num) return size.toDouble();
  switch (size) {
    case 'small':
      return 10;
    case 'large':
      return 14;
    case 'huge':
      return 18;
    default:
      return 12;
  }
}

double _getHeaderFontSize(int level) {
  switch (level) {
    case 1:
      return 24;
    case 2:
      return 20;
    case 3:
      return 18;
    default:
      return 14;
  }
}













// import 'package:flutter_quill/quill_delta.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'dart:convert';
//
// pw.Widget quillDeltaToPdfWidget(String jsonDelta) {
//   print('object $jsonDelta');
//   final delta = Delta.fromJson(jsonDecode(jsonDelta));
//   final ops = delta.toJson();
//
//   final List<pw.Widget> widgets = [];
//   List<pw.InlineSpan> currentLineSpans = [];
//   int? currentHeaderLevel;
//
//   for (var op in ops) {
//     if (!op.containsKey('insert')) continue;
//
//     final text = op['insert'] as String;
//     final attrs = op['attributes'] ?? {};
//
//     // Determine if it's a header
//     final int? headerLevel = attrs['header'];
//     print('header for $text is ${attrs['header']}');
//     print('object ${_getFontSizeFromHeaderOrSize(headerLevel, attrs['size'])}');
//     final style = pw.TextStyle(
//       fontWeight: attrs['bold'] == true || headerLevel != null
//           ? pw.FontWeight.bold
//           : pw.FontWeight.normal,
//       fontStyle: attrs['italic'] == true ? pw.FontStyle.italic : pw.FontStyle.normal,
//       decoration: attrs['underline'] == true
//           ? pw.TextDecoration.underline
//           : pw.TextDecoration.none,
//       fontSize: _getFontSizeFromHeaderOrSize(headerLevel, attrs['size']),
//     );
//
//     final lines = text.split('\n');
//
//     for (int i = 0; i < lines.length; i++) {
//       final line = lines[i];
//
//       if (line.isNotEmpty) {
//         currentLineSpans.add(pw.TextSpan(text: line, style: style));
//       }
//
//       final isLastLine = i == lines.length - 1;
//
//
//       if (!isLastLine) {
//         if (currentLineSpans.isNotEmpty) {
//           final content = pw.RichText(
//             text: pw.TextSpan(children: currentLineSpans),
//           );
//
//
//           if (headerLevel != null) {
//             widgets.add(
//               pw.Padding(
//                 padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
//                 child: content,
//               ),
//             );
//           } else {
//             widgets.add(content);
//           }
//         } else {
//           widgets.add(pw.SizedBox(height: 10));
//         }
//
//         currentLineSpans = [];
//         currentHeaderLevel = null;
//       }
//     }
//   }
//
//   // Add any remaining spans
//   if (currentLineSpans.isNotEmpty) {
//     widgets.add(
//       pw.RichText(
//         text: pw.TextSpan(children: currentLineSpans),
//       ),
//     );
//   }
//
//   return pw.Column(
//     crossAxisAlignment: pw.CrossAxisAlignment.start,
//     children: widgets,
//   );
// }
//
// double _getFontSizeFromHeaderOrSize(int? header, dynamic size) {
//   if (header != null) {
//     switch (header) {
//       case 1:
//         return 24;
//       case 2:
//         return 20;
//       case 3:
//         return 18;
//     }
//   }
//
//   if (size is String) {
//     switch (size) {
//       case 'small':
//         return 10;
//       case 'large':
//         return 14;
//       case 'huge':
//         return 18;
//     }
//   } else if (size is num) {
//     return size.toDouble();
//   }
//
//   return 12;
// }
//
//
//
//
