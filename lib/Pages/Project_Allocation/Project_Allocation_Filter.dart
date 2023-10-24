import 'package:management_dashboard/API_Service/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:management_dashboard/Local_DB/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Project_Allocation_Model.dart';

class team_allocation_page_filter extends StatefulWidget {
  final Function(int, String, String, String, String, String, int, int, String)
      onFilterChanged;
  final Function fetch_employee_Data;
  final selectedManagerUserId;
  final selectedStartMonth;
  final selectedEndMonth;
  final defaultFromDate;
  final defaultToDate;
  final selectedStartMonthYear;
  final selectedEndMonthYear;
  final selectedManagerName;

  team_allocation_page_filter({
    super.key,
    required this.onFilterChanged,
    required this.fetch_employee_Data,
    required this.selectedManagerUserId,
    required this.selectedEndMonth,
    required this.selectedStartMonth,
    required this.defaultFromDate,
    required this.defaultToDate,
    required this.selectedEndMonthYear,
    required this.selectedStartMonthYear,
    required this.selectedManagerName,
  });

  @override
  State<team_allocation_page_filter> createState() =>
      _team_allocation_page_filterState();
}

class _team_allocation_page_filterState
    extends State<team_allocation_page_filter> {
  @override
  void didUpdateWidget(covariant team_allocation_page_filter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedManagerUserId != oldWidget.selectedManagerUserId ||
        widget.selectedStartMonth != oldWidget.selectedStartMonth ||
        widget.selectedEndMonth != oldWidget.selectedEndMonth ||
        widget.defaultFromDate != oldWidget.defaultFromDate ||
        widget.defaultToDate != oldWidget.defaultToDate ||
        widget.selectedStartMonthYear != oldWidget.selectedStartMonthYear ||
        widget.selectedEndMonthYear != oldWidget.selectedEndMonthYear) {
      selectedManagerUserId = widget.selectedManagerUserId;
    }
  }

  var savedFilters;
  var _ProjectAllocationFilterService = FilterService();
  int selectedManagerUserId = 76;
  String selectedManagerName = 'Muralikrishnan Vijayaraghavalou';
  String selectedManager = '';
  String LoggedUser = '';
  int Userid_selectedManager = 0;
  int UserId = 76;
  DateTime currentDate = DateTime.now();
  List<String> managers = [];
  List<int> user_id_manager = [];
  bool isWeekly = true;
  bool isEmployee = true;
  String defaultFromDate = 'aug';
  String defaultToDate = 'aug';
  TextEditingController textEditingController = TextEditingController();
  final TextEditingController managerController = TextEditingController();
  List<int> years = List.generate(DateTime.now().year, (index) => 2000 + index);
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
  String selectedStartMonth = 'August';
  String selectedEndMonth = 'August';
  int selectedStartMonthYear = DateTime.now().year;
  int selectedEndMonthYear = DateTime.now().year;

  int selectedYear = DateTime.now().year;
  String selectedMonth = 'January';

  String convertMonthToDateFormat(String month, int year, bool isstartmonth) {
    Map<String, String> monthMap = {
      'january': '01',
      'february': '02',
      'march': '03',
      'april': '04',
      'may': '05',
      'june': '06',
      'july': '07',
      'august': '08',
      'september': '09',
      'october': '10',
      'november': '11',
      'december': '12',
    };

    String monthAbbreviation = month.toLowerCase();
    if (monthMap.containsKey(monthAbbreviation)) {
      String? monthNumber = monthMap[monthAbbreviation];
      if (isstartmonth) {
        return '$year-$monthNumber-01';
      } else {
        int lastDayOfMonth = DateTime(year, int.parse(monthNumber!) + 1, 0).day;

        return '$year-$monthNumber-$lastDayOfMonth'; // need to change year.
      }
    } else {
      throw Exception('Invalid month: $month');
    }
  }

  void calculateDefaultDates() {
    DateTime currentDate = DateTime.now();
    DateTime firstDayOfPreviousMonth =
        DateTime(currentDate.year, currentDate.month - 1, 1);
    DateTime lastDayOfPreviousMonth =
        DateTime(currentDate.year, currentDate.month, 0);

    String defaultfromDate =
        "${firstDayOfPreviousMonth.year}-${firstDayOfPreviousMonth.month.toString().padLeft(2, '0')}-${firstDayOfPreviousMonth.day.toString().padLeft(2, '0')}";
    String defaulttoDate =
        "${lastDayOfPreviousMonth.year}-${lastDayOfPreviousMonth.month.toString().padLeft(2, '0')}-${lastDayOfPreviousMonth.day.toString().padLeft(2, '0')}";

    setState(() {
      defaultFromDate = defaultfromDate;
      defaultToDate = defaulttoDate;
    });
  }

  void initState() {
    super.initState();
    calculateDefaultDates();
    fetch_manager_Data(null);
    selectedMonth = selectedEndMonth;
    selectedManagerUserId = widget.selectedManagerUserId;
    selectedStartMonth = widget.selectedStartMonth;
    selectedEndMonth = widget.selectedEndMonth;
    selectedEndMonthYear = widget.selectedEndMonthYear;
    selectedStartMonthYear = widget.selectedStartMonthYear;
    setState(() {});
  }

  void applyFilter() {
    widget.onFilterChanged(
        selectedManagerUserId,
        selectedStartMonth,
        selectedEndMonth,
        defaultFromDate,
        defaultToDate,
        selectedMonth,
        selectedStartMonthYear,
        selectedEndMonthYear,
        selectedManagerName);
  }

  Future<int> fetch_manager_Data(empno) async {
    dynamic responseBody = await Networking.fetchData(
      apiUrl:
          'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetManagerHierarchy?reportingManagerCode=$empno', //${login_details().Empno}
      headers: {'Content-Type': 'application/json'},
      requestBody: {},
    );
    final managerData = List<Map<String, dynamic>>.from(responseBody);
    Map<String, dynamic> firstItem = managerData[0];
    managerData
        .sublist(1)
        .sort((a, b) => a['employeeName'].compareTo(b['employeeName']));
    managerData[0] = firstItem;

    managers =
        managerData.map<String>((manager) => manager['employeeName']).toList();
    user_id_manager =
        managerData.map<int>((manager) => manager['userId']).toList();
    if (managers.isNotEmpty) {
      Userid_selectedManager =
          managerData[0]['userId']; // Set default userIdSelectedManager
    } else {
      selectedManager = 'Select Manager';
      Userid_selectedManager = 0; // No managers available, so set to empty
    }
    return Userid_selectedManager;
  }

  void showManagerList(
      BuildContext context, TextEditingController managerController, managers) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredManagers = managers;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        // setState(() {

                        filteredManagers = managers
                            .where((manager) => manager
                                    .toLowerCase()
                                    .contains(value.toLowerCase())
                                ? true
                                : false)
                            .toList();
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: filteredManagers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(filteredManagers[index]),
                        onTap: () {
                          managerController.text = filteredManagers[index];
                          setState(() {
                            selectedManagerUserId = user_id_manager[index];
                            selectedManagerName = managerController.text;
                          });
                          Navigator.pop(context);
                        });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  int currentYearIndex(bool isStartMonth) {
    if (isStartMonth) {
      return years.indexOf(selectedStartMonthYear);
    } else {
      return years.indexOf(selectedEndMonthYear);
    }
  }

  int currentMonthIndex(bool isStartMonth) {
    if (isStartMonth) {
      return months.indexOf(selectedStartMonth);
    } else {
      return months.indexOf(selectedEndMonth);
    }
  }

  Future<void> fetchData_db() async {
    SharedPreferences userContext = await SharedPreferences.getInstance();
    LoggedUser = userContext.getString('UserCode') ?? '';

    var filter = TeamAllocationFilter();
    filter.filterName = textEditingController.text;
    filter.selectedManagerID = selectedManagerUserId.toString();
    filter.selectedManagerName = selectedManagerName;
    filter.selectedStartMonth = selectedStartMonth;
    filter.selectedStartYear = selectedStartMonthYear;
    filter.selectedEndYear = selectedEndMonthYear;
    filter.selectedEndMonth = selectedEndMonth;
    filter.userID = LoggedUser;

    var result = await _ProjectAllocationFilterService.saveProjectFilter(filter);
  }

  void _showMonthlyPicker(BuildContext context, bool isStartMonth) {
    final int currentYear = DateTime.now().year;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 200,
            child: Row(
              children: [
                // For Years
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (isStartMonth) {
                          selectedStartMonthYear = currentYear - index;
                        } else {
                          selectedEndMonthYear = currentYear - index;
                        }
                      });
                    },
                    children: List.generate(
                      currentYear - 1999,
                      (index) =>
                          Center(child: Text((currentYear - index).toString())),
                    ),
                  ),
                ),
                // For Months
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                        initialItem: currentMonthIndex(isStartMonth)),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (isStartMonth) {
                          selectedStartMonth = months[index];
                        } else {
                          selectedEndMonth = months[index];
                        }
                      });
                    },
                    children: months
                        .map((month) => Center(child: Text(month)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                defaultFromDate = convertMonthToDateFormat(
                    selectedEndMonth, selectedEndMonthYear, true);
                defaultToDate = convertMonthToDateFormat(
                    selectedEndMonth, selectedEndMonthYear, false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarButton(
      {required String text,
      required Color borderColor,
      required Color iconColor,
      required VoidCallback onTap,
      bool isStartMonth = true,
      required BuildContext
          context // Added parameter to distinguish between Start and End Month
      }) {
    String selectedText = isStartMonth
        ? "$selectedStartMonth $selectedStartMonthYear"
        : "$selectedEndMonth $selectedEndMonthYear";

    return InkWell(
      onTap: () {
        _showMonthlyPicker(context, isStartMonth);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
        ),
        padding: EdgeInsets.all(12.0), // Adjust the padding as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedText,
              style: TextStyle(
                color: Color(0xFF5C658B),
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF647DF5), // Background color
                shape: BoxShape.circle, // Circular shape
              ),
              padding: EdgeInsets.all(8.0), // Padding inside the circle
              child: Icon(
                Icons.calendar_today,
                size: 12.0,
                color: Colors.white, // Icon color (white)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPicker(List<Widget> items, ValueChanged<int> onChanged,
      {double width = 100.0}) {
    return Container(
      height: 150,
      width: width,
      child: CupertinoPicker(
        itemExtent: 30,
        onSelectedItemChanged: onChanged,
        children: items,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onTap: () {
                fetch_manager_Data(null); // updating the managers list
                showManagerList(context, managerController, managers);
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFDEEBFE)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  controller: managerController,
                  enabled: false, // Disable editing
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: selectedManagerName,
                    hintStyle: TextStyle(color: Color(0xFF9AA2C1)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    suffixIcon:
                        Icon(Icons.arrow_drop_down, color: Color(0xFF9AA2C1)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildCalendarButton(
                    text: selectedStartMonth,
                    borderColor: Color(0xFFDEEBFE),
                    iconColor: Colors.blue,
                    context: context,
                    onTap: () {
                      _showMonthlyPicker(context, true);
                    },
                    isStartMonth: true,
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: _buildCalendarButton(
                    text: selectedEndMonth,
                    borderColor: Color(0xFFDEEBFE),
                    iconColor: Colors.blue,
                    context: context,
                    onTap: () {
                      _showMonthlyPicker(context, false);
                    },
                    isStartMonth: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Container(
              height: 60,
              color: Color(0xFFDEEBFE),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Filter Name',
                      style: TextStyle(color: Color(0xFF5C658B)),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFDEEBFE)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter text...',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  InkWell(
                    onTap: () {
                      fetchData_db();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF647DF5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child:
                          Icon(Icons.download_for_offline, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10.0),
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
                      selectedMonth = selectedEndMonth;
                      applyFilter();
                      widget.fetch_employee_Data(selectedManagerUserId,
                          defaultFromDate, defaultToDate);
                      Navigator.pop(context);
                    },
                    child: Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
