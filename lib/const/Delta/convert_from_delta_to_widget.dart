import 'dart:convert';
import 'package:flutter/material.dart';

import 'fix_delta.dart';

Widget quillDeltaToWidget(String jsonDelta) {
  jsonDelta = fixQuillHeaderDelta(jsonDelta);
  final ops = jsonDecode(jsonDelta) as List<dynamic>;

  final List<Widget> widgets = [];
  List<InlineSpan> currentLineSpans = [];
  int? currentHeaderLevel;
  Map<String, dynamic>? lastAttrs;
  int listIndex = 1;
  String? lastListType;

  for (final op in ops) {
    final map = Map<String, dynamic>.from(op);
    final text = map['insert'] as String;
    final attrs = Map<String, dynamic>.from(map['attributes'] ?? {});
    lastAttrs = attrs;

    final style = TextStyle(
      fontWeight: attrs['header'] != null || attrs['bold'] == true
          ? FontWeight.bold
          : FontWeight.normal,
      fontStyle: attrs['italic'] == true ? FontStyle.italic : FontStyle.normal,
      decoration: attrs['underline'] == true ? TextDecoration.underline : TextDecoration.none,
      fontSize: attrs['header'] != null
          ? _getHeaderFontSize(attrs['header'])
          : _getFontSize(attrs['size']),
    );

    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.isNotEmpty) {
        currentLineSpans.add(TextSpan(text: line, style: style));
        if (attrs.containsKey('header')) {
          currentHeaderLevel = attrs['header'];
        }
      }

      final isLast = i == lines.length - 1;
      if (!isLast) {
        final lineWidget = RichText(
          text: TextSpan(children: currentLineSpans),
        );

        if (attrs.containsKey('list')) {
          final listType = attrs['list'];
          if (lastListType != listType) {
            listIndex = 1;
            lastListType = listType;
          }

          final bullet = listType == 'bullet' ? '·' : '${listIndex++}.';

          widgets.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('$bullet ', style: TextStyle(fontSize:
              attrs['header'] != null
                  ? _getHeaderFontSize(attrs['header'])
                  : _getFontSize(attrs['size']))),
                Expanded(child: lineWidget),
              ],
            ),
          );
        } else if (currentHeaderLevel != null) {
          widgets.add(
            DefaultTextStyle(
              style: TextStyle(fontSize: _getHeaderFontSize(currentHeaderLevel)),
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
    final lineWidget = RichText(
      text: TextSpan(children: currentLineSpans),
    );

    if (lastAttrs != null && lastAttrs.containsKey('list')) {
      final listType = lastAttrs['list'];
      final bullet = listType == 'bullet' ? '·' : '${listIndex++}.';

      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$bullet ', style: TextStyle(fontSize: 11)),
            Expanded(child: lineWidget),
          ],
        ),
      );
    } else if (currentHeaderLevel != null) {
      widgets.add(
        DefaultTextStyle(
          style: TextStyle(fontSize: _getHeaderFontSize(currentHeaderLevel)),
          child: lineWidget,
        ),
      );
    } else {
      widgets.add(lineWidget);
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}

double _getFontSize(dynamic size) {
  if (size == null) return 11;
  if (size is num) return size.toDouble();
  switch (size) {
    case 'small':
      return 9;
    case 'large':
      return 13;
    case 'huge':
      return 17;
    default:
      return 11;
  }
}

double _getHeaderFontSize(int? level) {
  switch (level) {
    case 1:
      return 23;
    case 2:
      return 19;
    case 3:
      return 17;
    default:
      return 13;
  }
}
