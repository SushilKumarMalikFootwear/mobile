import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  CustomDropDown(
      {required this.value,
      required this.hint,
      required this.onChange,
      required this.items,
      this.enabled = true});
  String hint;
  String? value;
  Function onChange;
  List<String> items;
  bool enabled;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      value: widget.value,
      hint: Text(widget.hint),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      isExpanded: true,
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.black45,
      ),
      iconSize: 30,
      buttonHeight: 35,
      buttonWidth: 1,
      buttonPadding: const EdgeInsets.only(left: 10),
      buttonHighlightColor: Colors.blue,
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      items: widget.items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: (value) {
        widget.onChange(value!);
      },
    );
  }
}
