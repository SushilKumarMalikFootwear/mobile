import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchableDropdown extends StatefulWidget {
  final String hintText;
  final Future<List<String>> Function(String) onChange;
  final int? maxLength;
  final TextEditingController controller;
  final Function(String) onSelect;

  const SearchableDropdown({
    super.key,
    required this.onSelect,
    required this.controller,
    this.maxLength,
    required this.onChange,
    required this.hintText,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      emptyBuilder:
          (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No Results Found!',
              style: TextStyle(color: Colors.grey),
            ),
          ),

      loadingBuilder:
          (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),

      // 🔥 This WILL now trigger correctly
      suggestionsCallback: (pattern) async {
        return await widget.onChange(pattern);
      },

      itemBuilder: (context, suggestion) {
        return ListTile(title: Text(suggestion));
      },

      onSelected: (suggestion) {
        widget.controller.text = suggestion;
        widget.onSelect(suggestion.trim());
        FocusScope.of(context).unfocus();

        // setState(() {});
      },

      builder: (context, typeAheadController, focusNode) {
        // 🔑 SYNC controllers
        typeAheadController.text = widget.controller.text;

        return TextField(
          controller: typeAheadController,
          focusNode: focusNode,
          maxLength: widget.maxLength,
          onChanged: (value) {
            widget.controller.text = value;
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: const UnderlineInputBorder(),
          ),
        );
      },
    );
  }
}
