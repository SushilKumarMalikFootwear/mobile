import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String label;
  final bool isMultiLine;
  final TextEditingController tc;
  final bool isObscureText;
  final Function? onChange;
  final bool required;
  const CustomText(
      {super.key,
      this.required = false,
      required this.label,
      this.isMultiLine = false,
      required this.tc,
      this.isObscureText = false,
      this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        obscureText: isObscureText,
        controller: tc,
        onChanged: (value) {
          if (onChange != null) {
            onChange!(value);
          }
        },
        validator: (value) {
          if (required && value.toString().trim().isEmpty) {
            return 'Please fill this field';
          }
          return null;
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
