import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class HeatMapGrid extends StatefulWidget {
  final bool isWeekly;
  final bool isEmployee;
  final int selectedYear;
  final String selectedMonth;
  final DateTime? currentWeek;
  final int currentStartMonth;
  final List<dynamic> data;
  //final List<dynamic> customers;
  //final List<dynamic> customeremployee;

  HeatMapGrid({
    required this.isWeekly,
    required this.isEmployee,
    required this.selectedYear,
    required this.selectedMonth,
    this.currentWeek,
    required this.currentStartMonth,
    required this.data,
    //required this.customers,
    //required this.customeremployee,
  });
  Future<List<double>> fetchData() async {
    // Call the API and fetch the data
    // This is a mock function; replace with your actual API call
    await Future.delayed(Duration(seconds: 1)); // Mocking API delay
    return [0.4, 0.7, 0.2, 0.55, 0.95];
  }

  @override
  _HeatMapGridState createState() => _HeatMapGridState();
}

class _HeatMapGridState extends State<HeatMapGrid> {
  int selectedRow = -1;
  List<String> rowNameParts = [];
  @override
  void didUpdateWidget(HeatMapGrid oldWidget) {
    groupData();
    //groupData1();
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStartMonth != widget.currentStartMonth ||
        oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.selectedMonth != widget.selectedMonth) {
      setState(() {
        currentStartMonth = widget.currentStartMonth;
      });
    }
    if (oldWidget.isEmployee != widget.isEmployee) {
      setState(() {});
    }
  }

  final List<String> allMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  DateTime? _currentWeek;
  int currentStartMonth = 0; // Or any default value you'd like
  List<String> employeeNames =
  List.generate(20, (index) => 'Employee ${index + 1}');
  List<String> customerNames =
  List.generate(20, (index) => 'Customer ${index + 1}');
  Color _getHeatMapColorByPercentage(double percentage) {
    // Transform percentage to a value between 0 and 1.
    double value = percentage / 100;
    if (value >= 0.75) return Color(0xFF52D7A8);
    if (value >= 0.61) return Color(0xFF8FE3C9);
    if (value >= 0.46) return Color(0xFFC0EDE4);
    if (value >= 0.36) return Color(0xFFEDC3D4);
    if (value >= 0.26) return Color(0xFFEA92A9);
    if (value == 0.00) return Color(0xFF9AA2C1);
    return Color(0xFFE94F73);
  }

  List<String> _getColumnLabels() {
    // print('selectedYear ${widget.selectedYear}');
    // print('currentStartMonth $currentStartMonth');
    // print('currentWeek ${widget.currentWeek}');
    if (widget.isWeekly) {
      List<String> weeks = [];
      DateTime date = widget.currentWeek ?? DateTime.now();
      for (int i = 0; i < 6; i++) {
        weeks.add('${DateFormat('dd MMM yyyy').format(date)}');
        date = date.add(Duration(days: 7));
      }
      // print("Weekly values: $weeks");
      return weeks;
    } else {
      final List<String> month = [];
      int monthIndex = widget.currentStartMonth;
      int year = widget.selectedYear;

      for (int i = 0; i < 6; i++) {
        if (monthIndex >= 12) {
          monthIndex = 0;
          year++;
        }
        month.add('${allMonths[monthIndex]} $year');
        monthIndex++;
      }
      return month;
    }
  }

  @override
  void initState() {
    super.initState();
    groupData();
    //groupData1();
  }

  List<Map<String, dynamic>> groupedData = [];

  void groupData() {
    // print('sample ${widget.data}');
    final groupedMap = groupBy(widget.data, (item) => item['userCode']);

    groupedData = groupedMap.entries.map((entry) {
      final userCode = entry.key;
      final userEntries = entry.value;
      final userName =
      userEntries.isNotEmpty ? userEntries.first['userName'] : '';

      final percentages = List.generate(6, (index) {
        // If there is a percentage available, use it; otherwise, use 0
        if (index < userEntries.length) {
          return userEntries[index]['percentage'];
        } else {
          return "0";
        }
      }).toList();

      return {
        'userCode': userCode,
        'userName': userName,
        'percentage': percentages,
      };
    }).toList();

    // Sort groupedData by userName in ascending order
    groupedData.sort((a, b) => a['userName'].compareTo(b['userName']));
    setState(() {});
  }

  String truncateName(String name) {
    List<String> parts = name.split(' ');
    if (parts.isEmpty) {
      return ""; // Return an empty string if no parts found
    }
    String firstName = parts[0].length > 10 ? parts[0].substring(0, 10) : parts[0];
    if (parts.length > 1 && parts[1].isNotEmpty) {
      String secondNameInitial = parts[1].substring(0, 1);
      return '$firstName.$secondNameInitial';
    }
    return firstName;
  }

  @override
  Widget build(BuildContext context) {
    List<String> columnLabels = _getColumnLabels();
    // List userCodes = groupedData.map((item) => item['userName']).toList();
    // List rowNames = userCodes;
    List userCodes = groupedData.map((item) => item['userName']).toList();
    List rowNames = userCodes;
    print('groupedData  $groupedData');
    print('rowNames  $rowNames');
    //print('groupedData1  $groupedData1');
    return Column(
      children: [
        // Month/Week names without the < and > icons (non-scrollable)
        Container(
          height: 50,
          child: Row(
            children: [
              SizedBox(width: 100),
              ...columnLabels.map((label) {
                List<String> parts = label.split(' ');
                return Expanded(
                  child: Center(
                    child: widget.isWeekly
                        ? Column(
                      children: [
                        Text(parts.length > 0 ? parts[0] : 'N/A'),
                        Text(parts.length > 1 ? parts[1] : 'N/A'),
                        Text(parts.length > 2 ? parts[2] : 'N/A'),
                      ],
                    )
                        : Text(label),
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        // Scrollable heatmap
        Expanded(
          child: ListView.builder(
            itemCount: rowNames.length,
            itemBuilder: (context, rowIndex) {
              return Container(
                height: 50,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (selectedRow == rowIndex) {
                              selectedRow = -1;
                            } else {
                              selectedRow = rowIndex;
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedRow == rowIndex
                                  ? rowNames[rowIndex]
                                  : truncateName(rowNames[rowIndex]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...List.generate(6, (colIndex) {
                      Color cellColor = Colors.grey;
                      String percentageText = '';
                      if (groupedData.isNotEmpty &&
                          groupedData[rowIndex] != null &&
                          groupedData[rowIndex].containsKey('percentage')) {
                        // Parse percentage, cast to int, and then convert to string with '%' symbol
                        percentageText = (double.parse(groupedData[rowIndex]
                        ['percentage'][colIndex])
                            .toInt())
                            .toString() +
                            '%';
                        cellColor = _getHeatMapColorByPercentage(double.parse(
                            groupedData[rowIndex]['percentage'][colIndex]));
                      }


                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Container(
                            margin: EdgeInsets.all(1.0), // Add this line
                            color: cellColor,
                            child: Center(
                              child: Text(
                                percentageText,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
