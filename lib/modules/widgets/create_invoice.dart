import 'package:flutter/material.dart';

import '../models/Invoice.dart';

class CreateInvoice extends StatefulWidget {
  final Invoice invoice;
  final String todo;
  final Function refreshChild;
  final Function switchChild;
  const CreateInvoice({super.key, required this.invoice, required this.refreshChild, required this.switchChild, required this.todo});

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
