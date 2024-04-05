import 'package:flutter/material.dart';

class SelectableListView extends StatefulWidget {
  final List<MapEntry<String, dynamic>> items;
  final List<dynamic> preSelectedValues;
  final Function(List<dynamic>) onSelectionChanged;
  final bool checkboxes;
  final bool radioButtons;

  SelectableListView(
      {Key? key,
      required this.items,
      required this.onSelectionChanged,
      required this.checkboxes,
      this.radioButtons = false,
      this.preSelectedValues = const []})
      : super(key: key);

  @override
  _SelectableListViewState createState() => _SelectableListViewState();
}

class _SelectableListViewState extends State<SelectableListView> {
  List<MapEntry<String, dynamic>> filteredItems = [];
  List<dynamic> selectedValues = [];
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValues = [...widget.preSelectedValues];
    selectedValue = widget.preSelectedValues.isNotEmpty
        ? widget.preSelectedValues[0]
        : null;
    filteredItems = widget.items;
  }

  void _searchItems(String enteredKeyword) {
    List<MapEntry<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = widget.items;
    } else {
      results = widget.items
          .where((item) =>
              item.key.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) => _searchItems(value),
            decoration: InputDecoration(
              labelText: 'Search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: (filteredItems.length > 0)
              ? (widget.radioButtons)
                  ? ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return RadioListTile<dynamic>(
                          // Use the same type as 'value'
                          title: Text(item.key),
                          value: item.value,
                          // Set the value from the filtered item
                          groupValue: selectedValue,
                          onChanged: (dynamic value) {
                            setState(() {
                              selectedValue = value;
                              widget.onSelectionChanged([selectedValue]);
                            });
                          },
                          // Check if the current item's value matches the selectedValue
                          selected: selectedValue ==
                              item.value, // Set selected based on comparison
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredItems[index].key),
                          leading: widget.checkboxes
                              ? Checkbox(
                                  value: selectedValues
                                      .contains(filteredItems[index].value),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedValues
                                            .add(filteredItems[index].value);
                                      } else {
                                        selectedValues
                                            .remove(filteredItems[index].value);
                                      }
                                      widget.onSelectionChanged(selectedValues);
                                    });
                                  },
                                )
                              : Icon(Icons.check),
                        );
                      },
                    )
              : const Text(
                  'There are no results for that search.',
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}
