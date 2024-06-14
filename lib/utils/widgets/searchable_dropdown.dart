import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchableDropdown extends StatefulWidget {
  final String hintText;
  final Function onChange;
  final int? maxLength;
  final TextEditingController controller;
  final Function onSelect;

  const SearchableDropdown(
      {required this.onSelect,
      required this.controller,
      this.maxLength,
      required this.onChange,
      required this.hintText,
      super.key});

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TypeAheadField<String>(
        noItemsFoundBuilder: (context) => Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5),
            child: const Text('No Results Found!')),
        suggestionsBoxDecoration:
            SuggestionsBoxDecoration(borderRadius: BorderRadius.circular(5)),
        loadingBuilder: (context) {
          return Container(
            child: const SizedBox(),
          );
        },
        textFieldConfiguration: TextFieldConfiguration(
          textAlign: TextAlign.start,
          controller: widget.controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            hintText: widget.hintText,
          ),
        ),
        suggestionsCallback: (pattern) {
          final results = widget.onChange(pattern);
          return results;
        },
        itemBuilder: (context, suggestion) {
          return Column(
            children: [
              ListTile(
                leading: Text(
                  suggestion,
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.1,
                height: 0.1,
              )
            ],
          );
        },
        onSuggestionSelected: (suggestion) {
          widget.controller.text = suggestion;
          widget.onSelect(suggestion.trim());
        },
      ),
    );
  }
}
