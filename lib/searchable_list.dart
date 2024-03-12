import 'package:flutter/material.dart';

class SelectableListView extends StatefulWidget {
  final List<MapEntry<String, dynamic>> items;
  final List<dynamic> selectedValues = [];

  SelectableListView({Key? key, required this.items}) : super(key: key);

  @override
  _SelectableListViewState createState() => _SelectableListViewState();
}

class _SelectableListViewState extends State<SelectableListView> {
  List<MapEntry<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
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

  List<dynamic> getSelected() {
    return widget.selectedValues;
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
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredItems[index].key),
                leading: Checkbox(
                  value: widget.selectedValues
                      .contains(filteredItems[index].value),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        widget.selectedValues.add(filteredItems[index].value);
                      } else {
                        widget.selectedValues
                            .remove(filteredItems[index].value);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
