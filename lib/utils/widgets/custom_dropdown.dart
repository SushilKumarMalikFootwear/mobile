import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  const CustomDropDown(
      {super.key, required this.value,
      required this.hint,
      required this.onChange,
      required this.items,
      this.enabled = true});
  final String hint;
  final String? value;
  final Function onChange;
  final List<String> items;
  final bool enabled;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField2(
        value: widget.value,
        hint: Text(widget.hint),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        isExpanded: true,
        items: widget.items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: (value) {
          widget.onChange(value!);
        },
      ),
    );
  }
}
