import 'package:flutter/material.dart';
import 'dart:convert';

import 'fix_delta.dart';


 Widget quillDeltaToWidget(String jsonDelta) {
   jsonDelta=fixQuillHeaderDelta(jsonDelta);
  final ops = jsonDecode(jsonDelta) as List<dynamic>;

  final List< Widget> widgets = [];
  List< InlineSpan> currentLineSpans = [];
  int? currentHeaderLevel;

  for (final op in ops) {
    final map = Map<String, dynamic>.from(op);
    final text = map['insert'] as String;
    final attrs = Map<String, dynamic>.from(map['attributes'] ?? {});

    final style =  TextStyle(
        fontWeight:attrs['header']!=null ?   FontWeight.bold: attrs['bold'] == true ?  FontWeight.bold :  FontWeight.normal,
        fontStyle: attrs['italic'] == true ?  FontStyle.italic :  FontStyle.normal,
        decoration: attrs['underline'] == true ?  TextDecoration.underline :  TextDecoration.none,
        fontSize:attrs['header']!=null
            ?attrs['header']==1?24:attrs['header']==2?20:attrs['header']==3?18:12
            :_getFontSize(attrs['size'])
    );

    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.isNotEmpty) {
        currentLineSpans.add( TextSpan(text: line, style: style));
        if (attrs.containsKey('header')) {
          currentHeaderLevel = attrs['header'];
        }
      }

      final isLast = i == lines.length - 1;
      if (!isLast) {
        // نهاية سطر - اطبعه مع header إن وُجد
        if (currentLineSpans.isEmpty) {
          widgets.add(  SizedBox(height: 10));
        } else {
          final lineWidget = RichText(
            text: TextSpan(children: currentLineSpans),
          );

          if (currentHeaderLevel != null) {
            widgets.add(
              DefaultTextStyle(
                style: TextStyle(fontSize: _getHeaderFontSize(currentHeaderLevel)),
                child: lineWidget,
              ),
            );
            currentHeaderLevel = null; // نعيد الضبط بعد الطباعة
          } else {
            widgets.add(lineWidget);
          }
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
    if (currentHeaderLevel != null) {
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

double _getHeaderFontSize(int level ) {
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