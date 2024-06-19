import 'package:flutter/material.dart';

Future<DateTime> selectDate(BuildContext context, DateTime initialDate,
    {DateTime? firstDate}) async {
  DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2023),
      lastDate: DateTime(2050));
  return date!;
}