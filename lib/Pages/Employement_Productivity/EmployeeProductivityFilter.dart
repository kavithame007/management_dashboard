import 'package:management_dashboard/API_Service/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Local_DB/db_service.dart';
import 'EmployeeProductivity_Model.dart';

class EmployeeProductivityFilterLayout extends StatefulWidget {
  final Function(
      String?, String?, String?, String?, int, int, DateTime?, bool, bool)
  onFilterChanged;
  const EmployeeProductivityFilterLayout({super.key, required this.onFilterChanged});

  @override
  State<EmployeeProductivityFilterLayout> createState() => _EmployeeProductivityFilterLayout();
}

class _EmployeeProductivityFilterLayout extends State<EmployeeProductivityFilterLayout> {
  var _EmployeeProductivityFilterService = FilterService();
  int selectedYear = DateTime.now().year;
  List<int> years = List.generate(DateTime.now().year - 1999,
          (index) => 2000 + index); // Adjusted to ensure current year is included

  String filterName = '';
  TextEditingController managerController = TextEditingController();
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  late String selectedMonthName = 'January';
  late int selectedMonth = 0;
  DateTime startOfWeek(DateTime date) {
    final daysToMonday = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToMonday));
  }

  String? validationMessage; // Declare validationMessage variable
  _EmployeeProductivityFilterLayout() {
    // selectedMonthName = months[DateTime.now().month - 1];
    // selectedMonth = DateTime.now().month - 1;
    _currentWeek = startOfWeek(DateTime.now());
  }

  List<String> managers = [];
  List<String> customers = [];
  String? selectedManager = null;
  String? selectedManagerName = null;
  String? selectedCustomerName = null;
  DateTime? _currentWeek;
  bool isWeekly = false;
  bool isEmployee = true; // By default, let's keep it as Employee.
  List<Map<String, dynamic>> managerdatalist = [];
  List<Map<String, dynamic>> customerdatalist = [];
  String? selectedCustomer = null;
  TextEditingController filterNameController = TextEditingController();

  void initState() {
    super.initState();
    _fetch_manager(null);
    _fetch_customer(76);
    setState(() {});
  }

  void _showDatePickerBasedOnToggle() {
    if (isWeekly) {
      _showWeeklyPicker();
    } else {
      _showMonthlyPicker(context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  List<String> getAvailableMonths(int year) {
    if (year == DateTime.now().year) {
      return months.sublist(0, DateTime.now().month);
    }
    return months;
  }

  List<String> getMondays(int year, String month) {
    int monthIndex = months.indexOf(selectedMonthName) + 1;

    DateTime firstDateOfMonth = DateTime(year, monthIndex, 1);
    List<String> mondays = [];

    for (int i = 0; i < 31; i++) {
      DateTime date = firstDateOfMonth.add(Duration(days: i));
      if (date.weekday == DateTime.monday && date.month == monthIndex) {
        mondays.add(DateFormat('dd').format(date));
      }
      if (date.month != monthIndex) break;
    }
    return mondays;
  }

  void applyFilter() {
    widget.onFilterChanged(
        selectedManager,
        selectedManagerName,
        selectedCustomer,
        selectedCustomerName,
        selectedYear,
        selectedMonth,
        _currentWeek,
        isWeekly,
        isEmployee);

    print(
        "Filter values applied: $selectedManager,$selectedManagerName,$selectedCustomer,$selectedCustomerName, $selectedYear, $selectedMonth , $_currentWeek,$isEmployee , $isWeekly");
  }

  Future<List<Map<String, dynamic>>> _fetch_manager(empno) async {
    dynamic responseBody = await Networking.fetchData(
      apiUrl:
      'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetManagerHierarchy?reportingManagerCode=$empno',
      headers: {'Content-Type': 'application/json'},
      requestBody: {},
    );

    List<Map<String, dynamic>> result = [];

    if (responseBody is List) {
      for (var item in responseBody) {
        if (item is Map<String, dynamic> &&
            item.containsKey('employeeCode') &&
            item.containsKey('employeeName')) {
          result.add({
            'userId': item['userId'].toString(),
            'employeeName': item['employeeName'],
          });
        }
      }
    }
    managerdatalist = result;
    setState(() {});
    return result;
  }

  Future<List<Map<String, dynamic>>> _fetch_customer(managerid) async {
    dynamic responseBody = await Networking.fetchData(
      apiUrl:
      'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetClientList',
      headers: {'Content-Type': 'application/json'},
      requestBody: {
        "userID": managerid,
        "OrganizationId": 2,
        "Fromdate": "2023-02-06",
        "Interval": 6,
        "Mode": 0,
        "Option": "employee",
        "TimeOff": 2
      },
    );

    List<Map<String, dynamic>> result = [];

    if (responseBody is List) {
      for (var item in responseBody) {
        if (item is Map<String, dynamic> &&
            item.containsKey('projectId') &&
            item.containsKey('projectName')) {
          result.add({
            'projectId': item['projectId'].toString(),
            'projectName': item['projectName'],
          });
        }
      }
    }
    customerdatalist = result;
    setState(() {});
    return result;
  }

  int currentYearIndex() {
    return years.indexOf(selectedYear);
  }

  int currentMonthIndex() {
    return months.indexOf(selectedMonthName);
  }

  int currentWeekIndex(List<String> mondays) {
    return mondays.indexOf(DateFormat('dd').format(_currentWeek!));
  }

  void _showMonthlyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogState) {
            return AlertDialog(
              content: Container(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: currentYearIndex()),
                        onSelectedItemChanged: (index) {
                          dialogState(() {
                            selectedYear = years[index];
                            selectedMonthName = getAvailableMonths(selectedYear)[0];
                            selectedMonth = months.indexOf(selectedMonthName);
                          });
                        },
                        children: years.map((year) => Center(child: Text(year.toString()))).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: currentMonthIndex()),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedMonthName = getAvailableMonths(selectedYear)[index];
                            selectedMonth = months.indexOf(selectedMonthName);
                          });
                        },
                        children: getAvailableMonths(selectedYear).map((month) => Center(child: Text(month))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showWeeklyPicker() {
    List<String> availableMonths = getAvailableMonths(selectedYear);
    List<String> mondays = getMondays(selectedYear, selectedMonthName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: Container(
                height: 200,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: currentYearIndex()),
                        onSelectedItemChanged: (index) {
                          selectedYear = years[index];
                          availableMonths = getAvailableMonths(selectedYear);
                          selectedMonthName = availableMonths[0];
                          mondays = getMondays(selectedYear, selectedMonthName);
                          setState(() {}); // Trigger a re-build
                        },
                        children: years.map((year) => Center(child: Text(year.toString()))).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: availableMonths.indexOf(selectedMonthName)),
                        onSelectedItemChanged: (index) {
                          selectedMonthName = availableMonths[index];
                          selectedMonth = months.indexOf(selectedMonthName);
                          mondays = getMondays(selectedYear, selectedMonthName);
                          setState(() {}); // Trigger a re-build
                        },
                        children: availableMonths.map((month) => Center(child: Text(month))).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: currentWeekIndex(mondays)),
                        onSelectedItemChanged: (index) {
                          _currentWeek = DateTime(selectedYear, selectedMonth + 1, int.parse(mondays[index]));
                        },
                        children: mondays.map((monday) => Center(child: Text(monday))).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  Widget buildPicker(
      List<Widget> items, ValueChanged<int> onSelectedItemChanged,
      {double width = 100.0}) {
    return Container(
      height: 150,
      width: width,
      child: CupertinoPicker(
        itemExtent: 30,
        onSelectedItemChanged: onSelectedItemChanged,
        children: items,
      ),
    );
  }

  void _showManagerDialog() {
    TextEditingController searchController = TextEditingController();

    List<Map<String, dynamic>> filteredManagers = List.from(managerdatalist);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Select Manager"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Search Manager",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        filteredManagers = managerdatalist
                            .where((manager) => manager['employeeName']
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                            .toList();
                        setState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 250.0,
                      child: ListView.builder(
                        itemCount: filteredManagers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(filteredManagers[index]['employeeName']
                                .toString()),
                            onTap: () async {
                              selectedManager =
                              filteredManagers[index]['userId'] as String?;
                              selectedManagerName = filteredManagers[index]
                              ['employeeName'] as String?;
                              await _fetch_customer(selectedManager);
                              this.setState(() {});
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerDialog() {
    TextEditingController searchController = TextEditingController();

    List<Map<String, dynamic>> filteredCustomers = List.from(customerdatalist);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Select Customer"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Search Customer",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredCustomers = customerdatalist
                              .where((customer) => customer['customerName']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 250.0,
                      child: ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(filteredCustomers[index]['projectName']
                                .toString()),
                            onTap: () {
                              this.setState(() {
                                selectedCustomer = filteredCustomers[index]
                                ['projectId'] as String?;
                                selectedCustomerName = filteredCustomers[index]
                                ['projectName'] as String?;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> fetchData() async {
    if (filterNameController.text.trim().isEmpty) {
      setState(() {
        validationMessage = "Filter name is required!";
      });
      return;
    }
    // clear validation message if any
    setState(() {
      validationMessage = null;
    });
    var filter = EmployeeProductivityFilter();
    filter.selectedManagerID = selectedManager;
    filter.selectedCustomerID = selectedCustomer;
    filter.selectedManagerName = selectedManagerName;
    filter.selectedCustomerName = selectedCustomerName;
    filter.isWeekly = isWeekly;
    filter.isEmployee = isEmployee;
    filter.userID = 'E1129';
    filter.selectedYear = selectedYear;
    filter.selectedMonth = 2;
    filter.selectedDate = isWeekly ? _currentWeek : DateTime(selectedYear, 2, 1);
    filter.filterName = filterNameController.text;

    var result = await _EmployeeProductivityFilterService.saveEmployeeFilter(filter);
    print('Database $result');

    var get = await _EmployeeProductivityFilterService.readEmployeeFilter();
    print('GetAll $get');
  }

  @override
  Widget build(BuildContext context) {
    Color onColor = Color(0xFF5C658B);
    Color offColor = Color(0xFF9AA2C1);
    Color thumbColor = Colors.white;  // Thumb color remains consistent
    var mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
          bottom: mediaQuery.viewInsets
              .bottom, // This will take care of the keyboard overlap issue.
          left: 10.0,
          right: 10.0,
          top: 10.0),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensure it's set to min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Filter',
                style: TextStyle(
                  color: Color(0xFF5C658B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Color(0xFFDEEBFE), thickness: 2.0),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: _showManagerDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Color(0xFFDEEBFE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedManager != null
                            ? managerdatalist
                            .firstWhere((element) =>
                        element['userId'] ==
                            selectedManager)['employeeName']
                            .toString()
                            : "Select Manager",
                        style: TextStyle(color: Color(0xFF9AA2C1)),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('Monthly'),
                    Switch(
                      value: isWeekly,
                      onChanged: (bool value) {
                        setState(() {
                          isWeekly = value;
                        });
                      },
                      activeTrackColor: onColor,
                      inactiveTrackColor: offColor,
                      thumbColor: MaterialStateProperty.all(Colors.white),
                      trackColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return onColor;
                        }
                        return offColor;
                      }),
                    ),
                    Text('Weekly'),
                    IconButton(
                      icon: Icon(Icons.calendar_month_rounded,
                          color: Color(0xFF647DF5)),
                      onPressed: _showDatePickerBasedOnToggle,
                    ),
                    Row(
                      children: [
                        Text(isEmployee ? 'Employee' : 'Customer', style: TextStyle(color: Color(0xFF9AA2C1))),
                        Switch(
                          value: isEmployee,
                          onChanged: (bool value) {
                            setState(() {
                              isEmployee = value;
                            });
                          },
                          activeTrackColor: onColor,
                          inactiveTrackColor: offColor,
                          thumbColor: MaterialStateProperty.all(Colors.white),
                          trackColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return onColor;
                            }
                            return offColor;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !isEmployee, // Show only if isEmployee is false
                child: GestureDetector(
                  onTap: _showCustomerDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Color(0xFFDEEBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCustomer != null
                              ? customerdatalist
                              .firstWhere((element) =>
                          element['projectId'] ==
                              selectedCustomer)['projectName']
                              .toString()
                              : "Select Customer",
                          style: TextStyle(color: Color(0xFF9AA2C1)),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0),

// Add the validation message here
              if (validationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    validationMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                SizedBox.shrink(),
              SizedBox(
                height:
                50.0, // Adjust this value to match the height of the "Select Manager" box
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFDEEBFE),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        // Nested row for the 'Filter' text and the info icon
                        children: [
                          Text('Filter Name', style: TextStyle(color: Color(0xFF5C658B), fontSize: 16)),
                          SizedBox(
                              width:
                              8.0), // Some spacing between the text and the icon
                          // Icon(Icons.info, color: Colors.blue), // Adjust the icon color as needed
                        ],
                      ),
                      Expanded(  // Added Expanded widget to allow the TextField to take all available space
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),  // Add some padding to separate from adjacent widgets
                          child: TextField(
                            controller: filterNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),  // This will make the TextField rounded
                                borderSide: BorderSide.none,  // This will hide the default border
                              ),
                              filled: true,
                              fillColor: Colors.white,  // This will fill the TextField with white color
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await fetchData();
                        },
                        child: CircleAvatar(
                          backgroundColor: Color(0xFF647DF5), // This sets the background color
                          radius: 24, // Adjust the size of the circle as required
                          child: Icon(Icons.save, color: Colors.white, size: 24),  // Set the icon color to white
                        ),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.0), // Spacing

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF647DF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        applyFilter();
                        Navigator.pop(context);
                      },
                      child: Text('Apply'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
