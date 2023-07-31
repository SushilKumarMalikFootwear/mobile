import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

customBottomSheet(BuildContext context, Widget child, {bool showCross = true}) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (context) => Stack(children: [
      child,
      Positioned(
        top: 4,
        right: 4,
        child: Visibility(
          visible: showCross,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child:  Icon(
              Icons.cancel,
              color: Colors.grey.shade50,
            ),
          ),
        ),
      )
    ]),
    enableDrag: false,
  );
}
