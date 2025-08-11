import 'package:flutter/material.dart';

class SelectLabel extends StatefulWidget {
  final List<String> options;
  final List<String> selectedValues;
  final Function(List<String>) onSelectionChanged;

  const SelectLabel({
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  _SelectLabelState createState() => _SelectLabelState();
}

class _SelectLabelState extends State<SelectLabel> {
  List<String> selected = [];
  List<String> filteredOptions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedValues);
  }

  void filterList(String query) {
    setState(() {
      filteredOptions = widget.options
          .where((label) => label.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSelection(String label) {
    setState(() {
      if (selected.contains(label)) {
        selected.remove(label);
      } else {
        selected.add(label);
      }
    });
  }

  void addNewLabel() {
    final newLabel = searchController.text.trim();
    if (newLabel.isNotEmpty && !widget.options.contains(newLabel)) {
      setState(() {
        widget.options.insert(0, newLabel);
        filteredOptions = List.from(widget.options);
      });
      searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search or add label",
                        border: UnderlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onChanged: filterList,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      widget.onSelectionChanged(selected);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredOptions.length,
                  itemBuilder: (context, index) {
                    final label = filteredOptions[index];
                    final isSelected = selected.contains(label);
                    return ListTile(
                      title: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () => toggleSelection(label),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewLabel,
        child: const Icon(Icons.add),
      ),
    );
  }
}
