import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCheckBox extends StatefulWidget {
  bool isSelected;
  Function onClicked;
  String label;
  bool enabled;
  CustomCheckBox(
      {super.key, required this.isSelected,
      required this.onClicked,
      required this.label,
      this.enabled = true});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            onTap: () {
              if (widget.enabled) {
                widget.isSelected = !widget.isSelected;
                widget.onClicked(widget.isSelected);
                setState(() {});
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    widget.isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: widget.isSelected
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.6),
                    size: 25,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    widget.label,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
