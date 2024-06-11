import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String label;
  final bool isMultiLine;
  final TextEditingController tc;
  final bool isObscureText;
  final Function? onChange;
  const CustomText(
      {super.key,
      required this.label,
      this.isMultiLine = false,
      required this.tc,
      this.isObscureText = false,
      this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        obscureText: isObscureText,
        controller: tc,
        onChanged: (value) {
          if (onChange != null) {
            onChange!(value);
          }
        },
        maxLines: isMultiLine ? 4 : 1,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.deepPurple)),
            hintText: label,
            label: Text(label),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
