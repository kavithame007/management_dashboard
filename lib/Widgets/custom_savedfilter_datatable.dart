import 'package:flutter/material.dart';

class CustomDataTable extends StatefulWidget {
  final List<dynamic> data; // Pass the data directly to the widget

  CustomDataTable({required this.data});

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = widget.data; // Initialize with the full data
  }

  void filterData(String query) {
    setState(() {
      filteredData = widget.data.where((item) {
        final managerID = item["FilterName"].toString().toLowerCase();
        final managerName = item["selectedManagerName"].toString().toLowerCase();
        return managerID.contains(query) || managerName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (query) {
            filterData(query.toLowerCase());
          },
          decoration: InputDecoration(labelText: "Search"),
        ),
        DataTable(
          columns: [
            DataColumn(label: Text("Filter Name")), // Define your table columns
            DataColumn(label: Text("Date")),
          ],
          rows: filteredData.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item["FilterName"].toString())),
                DataCell(Text(item["selectedManagerName"].toString())),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
