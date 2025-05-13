import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  OverlayState? overlayState;
  OverlayEntry? overlayEntry;
  OverlayEntry? overlayEntry2;
  bool showOverlay = false;
  int index = 0;
  List<Widget> widgets = [
    Container(height: 40, width: 60, color: Colors.transparent),
    Container(height: 40, width: 60, color: Colors.transparent),
    Container(
      height: 300,
      width: 300,
      color: Colors.green,
      child: TextButton(
        child: const Text('Click Me'),
        onPressed: () {
        },
      ),
    ),
    Container(
      height: 300,
      width: 300,
      color: Colors.black,
      child: TextButton(
        child: const Text('Click Me'),
        onPressed: () {
          // print('Clicked');
        },
      ),
    ),
  ];
  final layerLink = LayerLink();
  final textButtonFocusNode = FocusNode();
  final textButtonFocusNode1 = FocusNode();

  void _showOverlay(BuildContext context, int index) async {
    overlayState = Overlay.of(context);

    overlayEntry = OverlayEntry(
        maintainState: true,
        builder: (context) {
          return Positioned(
            left: index == 0
                ? MediaQuery.of(context).size.width * 0.43
                : MediaQuery.of(context).size.width * 0.5,
            top: MediaQuery.of(context).size.height * 0.09,
            child: TextButton(
              onPressed: () {},
              onHover: (val) {
                if (val && showOverlay) {
                  if (index == 0) {
                    textButtonFocusNode.requestFocus();
                  } else if (index == 1) {
                    textButtonFocusNode1.requestFocus();
                  }
                } else {
                  if (index == 0) {
                    textButtonFocusNode.unfocus();
                  } else if (index == 1) {
                    textButtonFocusNode1.unfocus();
                  }
                }
              },
              child: widgets[index],
            ),
          );
        });
    overlayEntry2 = OverlayEntry(
        maintainState: true,
        builder: (context) {
          return Positioned(
            left: index == 0
                ? MediaQuery.of(context).size.width * 0.43
                : MediaQuery.of(context).size.width * 0.5,
            top: MediaQuery.of(context).size.height * 0.13,
            child: TextButton(
              onPressed: () {},
              onHover: (val) {
                if (val && showOverlay) {
                  if (index == 0) {
                    textButtonFocusNode.requestFocus();
                  } else if (index == 1) {
                    textButtonFocusNode1.requestFocus();
                  }
                } else {
                  if (index == 0) {
                    textButtonFocusNode.unfocus();
                  } else if (index == 1) {
                    textButtonFocusNode1.unfocus();
                  }
                }
              },
              child: widgets[index + 2],
            ),
          );
        });

    // overlayState!.insert(overlayEntry!);
    overlayState!.insertAll([overlayEntry!, overlayEntry2!]);
  }

  void removeOverlay() {
    overlayEntry!.remove();
    overlayEntry2!.remove();
  }

  @override
  void initState() {
    super.initState();
    textButtonFocusNode.addListener(() {
      if (textButtonFocusNode.hasFocus) {
        _showOverlay(context, 0);
      } else {
        removeOverlay();
      }
    });
    textButtonFocusNode1.addListener(() {
      if (textButtonFocusNode1.hasFocus) {
        _showOverlay(context, 1);
      } else {
        removeOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              focusNode: textButtonFocusNode,
              onHover: (val) {
                if (val) {
                  textButtonFocusNode.requestFocus();
                  showOverlay = true;
                }
              },
              onPressed: () {},
              child: const Text('Hover'),
            ),
            TextButton(
              focusNode: textButtonFocusNode1,
              onHover: (val) {
                if (val) {
                  textButtonFocusNode1.requestFocus();
                  showOverlay = true;
                }
              },
              onPressed: () {},
              child: const Text('Hover'),
            ),
          ],
        ),
      ),
    );
  }
}
