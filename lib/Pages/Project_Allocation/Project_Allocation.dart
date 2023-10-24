import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:management_dashboard/Widgets/pie_chart.dart';
import 'package:management_dashboard/Widgets/custom_data_table.dart';
import 'package:management_dashboard/Widgets/bottom_bar.dart';
import 'package:management_dashboard/API_Service/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Local_DB/db_service.dart';
import '../../Local_DB/repository.dart';
import '../../Widgets/bar_chart.dart';
import 'Project_Allocation_Filter.dart';

class Teamallocation_page extends StatefulWidget {
  const Teamallocation_page({Key? key});
  @override
  State<Teamallocation_page> createState() => _Teamallocation_pageState();
}

class _Teamallocation_pageState extends State<Teamallocation_page> {
  List<dynamic> projectData = [];
  bool showPieChart = false;
  final FocusNode _searchFocusNode = FocusNode();
  int selectedManagerUserId = 76;
  String selectedManager = '';
  List<Map<String, dynamic>> savedFilters = [];
  int Userid_selectedManager = 0;
  var _FilterService = FilterService();
  //String filter_query = 'Weekly, start date =07/03/23; Manager=All';
  int UserId = 76;
  DateTime currentDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> employeedetails = [];
  List<String> managers = [];
  List<int> user_id_manager = [];
  //bool isWeekly = true;
  bool isEmployee = true;
  String defaultFromDate = 'aug';
  String defaultToDate = 'aug';
  int selectedStartMonthYear = DateTime.now().year;
  int selectedEndMonthYear = DateTime.now().year;
  String selectedmonthyear = "";
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
  String selectedManagerName =
      'Muralikrishnan Vijayaraghavalou'; // Login user manager name
  String selectedStartMonth = 'August';
  String selectedEndMonth = 'August';
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
        // Calculate the last day of the selected month
        int lastDayOfMonth = DateTime(year, int.parse(monthNumber!) + 1, 0).day;

        return '$year-$monthNumber-$lastDayOfMonth';
      }
    } else {
      // Handle invalid month input
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

  void handleDropdownChange(String? newValue) {
    if (newValue != null) {
      final parts = newValue.split(' '); // Split by space
      if (parts.length == 2) {
        final selectedMonth = parts[0];
        final selectedYear = int.tryParse(parts[1]);
        if (selectedYear != null) {
          setState(() {
            this.selectedMonth = selectedMonth;
            this.selectedYear = selectedYear;
            selectedmonthyear = "$selectedMonth $selectedYear";
            defaultFromDate =
                convertMonthToDateFormat(selectedMonth, selectedYear, true);
            defaultToDate =
                convertMonthToDateFormat(selectedMonth, selectedYear, false);
            fetch_employee_Data(
                selectedManagerUserId, defaultFromDate, defaultToDate);
          });
        }
      }
    }
  }

  void initState() {
    super.initState();
    calculateDefaultDates();
    DateTime previousMonthDate = currentDate.subtract(Duration(days: 30));
    selectedmonthyear = DateFormat('MMMM y').format(previousMonthDate);
    selectedEndMonth = DateFormat('MMMM').format(previousMonthDate);
    selectedEndMonthYear = previousMonthDate.year;
    DateTime startMonthDate =
        previousMonthDate.subtract(Duration(days: 30 * 5));
    selectedStartMonth = DateFormat('MMMM').format(startMonthDate);
    selectedStartMonthYear = startMonthDate.year;
    fetch_employee_Data(UserId, defaultFromDate, defaultToDate);
    selectedMonth = selectedEndMonth;
    selectedYear = this.selectedYear;
    selectedmonthyear = "$selectedMonth $selectedYear";
    generateMonthYearList(selectedStartMonth, selectedStartMonthYear,
        selectedEndMonth, selectedEndMonthYear);
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return team_allocation_page_filter(
            defaultFromDate: defaultFromDate,
            defaultToDate: defaultToDate,
            selectedEndMonth: selectedEndMonth,
            selectedManagerUserId: selectedManagerUserId,
            selectedStartMonth: selectedStartMonth,
            selectedEndMonthYear: selectedEndMonthYear,
            selectedStartMonthYear: selectedStartMonthYear,
            selectedManagerName: selectedManagerName,
            onFilterChanged: (int value1,
                String str1,
                String str2,
                String str3,
                String str4,
                String str5,
                int startmonthyear,
                int endmonthyear,
                String str6) {
              selectedManagerUserId = value1;
              selectedStartMonth = str1;
              selectedEndMonth = str2;
              defaultFromDate = str3;
              defaultToDate = str4;
              selectedMonth = str5;
              selectedManagerName = str6;
              selectedStartMonthYear = startmonthyear;
              selectedEndMonthYear = endmonthyear;
              selectedmonthyear = '$selectedEndMonth $selectedEndMonthYear';
              setState(() {});
            },
            fetch_employee_Data: fetch_employee_Data,
          );
        });
  }

  void fetch_employee_Data(userid, defaultFromDate, defaultToDate) async {
    dynamic responseData = await Networking.fetchData(
      apiUrl:
          'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetProjectAllocation',
      headers: {
        'Content-Type': 'application/json',
      },
      requestBody: {
        "userID": userid,
        "OrganizationId": 2,
        "Fromdate": defaultFromDate,
        "ToDate": defaultToDate,
      },
    );
    employeedetails = await responseData;
    setState(() {});
  }

  String extractDate(String iso8601String) {
    DateTime parsedDate = DateTime.parse(iso8601String);
    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
  }

  void _showSavedFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Saved Filters"),
          content: Container(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              itemCount: savedFilters.length,
              itemBuilder: (context, index) {
                final filter = savedFilters[index];
                return InkWell(
                  onTap: () {
                    selectedManagerUserId =
                        int.parse(filter['selectedManagerID']);
                    selectedStartMonth = filter['selectedStartMonth'];
                    selectedEndMonth = filter['selectedEndMonth'];
                    selectedStartMonthYear = filter['selectedStartYear'];
                    selectedEndMonthYear = filter['selectedEndYear'];
                    selectedmonthyear =
                        '${filter['selectedEndMonth']} ${filter['selectedEndYear']}';
                    defaultFromDate = convertMonthToDateFormat(
                        selectedStartMonth, selectedStartMonthYear, true);
                    defaultToDate = convertMonthToDateFormat(
                        selectedEndMonth, selectedEndMonthYear, false);
                    fetch_employee_Data(
                        selectedManagerUserId, defaultFromDate, defaultToDate);
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text('${filter['FilterName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ManagerName: ${filter['selectedManagerName']}'),
                        Text(
                            '${filter['selectedStartMonth']}, ${filter['selectedStartYear']} To ${filter['selectedEndMonth']}, ${filter['selectedEndYear']}'),
                        Text('userID: ${filter['UserID']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        var repos = Repository();
                        var table = "EmployeeProductivityFilter";
                        var data =
                            await repos.deleteDataByID(table, filter['id']);
                        if (data == 1) {
                          savedFilters.removeAt(index);
                          setState(() {
                            savedFilters;
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<String> generateMonthYearList(
      String startMonth, int startYear, String endMonth, int endYear) {
    List<String> result = [];
    int currentYear = startYear;
    String currentMonth = startMonth;
    int endMonthIndex = months.indexOf(endMonth) + 1;
    if (endMonthIndex == 12) {
      endMonth = months[endMonthIndex - 2];
    } else if (endMonthIndex == 11) {
      endMonth = months[endMonthIndex - 1];
    } else {
      endMonth = months[endMonthIndex];
    }
    while (!(currentYear == endYear &&
        currentMonth.toLowerCase() == endMonth.toLowerCase())) {
      result.add('$currentMonth $currentYear');
      if (currentMonth == 'december') {
        currentMonth = 'january';
        currentYear++;
      } else {
        int nextMonthIndex = months.indexOf(currentMonth) + 1;
        if (nextMonthIndex >= 12) {
          nextMonthIndex = 0; // Reset to January
          currentYear++;
        }
        currentMonth = months[nextMonthIndex];
      }
    }
    if (endMonthIndex == 11) {
      result.add('$endMonth $endYear');
    }
    if (endMonthIndex == 12) {
      result.add('December $endYear');
    }
    return result.reversed.toList();
  }

  Future<void> fetchData() async {
    var get = await _FilterService.readProjectFilter();
    savedFilters = get;
    _showSavedFilters();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<String> monthYearList = generateMonthYearList(selectedStartMonth,
        selectedStartMonthYear, selectedEndMonth, selectedEndMonthYear);

    return Scaffold(
      backgroundColor: Color(0xFFEFF5FE),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF5FE),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Team Allocation",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.only(left: 20.0, right: 0.0),
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.account_circle_rounded,
              color: Color(0xFF647DF5),
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'ProfileSettings');
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.expand_more,
              color: Color(0xFF9BA3C2),
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'ProfileSettings');
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  fetchData();
                },
                child: ColoredBox(
                  color: Color(0XFFDEEBFE),
                  child: Row(
                    children: [
                      Text(
                        "Select Month:$selectedmonthyear",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: DropdownButton<String>(
                      items: monthYearList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: selectedmonthyear, //need to add year
                      onChanged: (String? newValue) {
                        handleDropdownChange(newValue);
                      },
                    ),
                  ),
                  Spacer(),
                  Text(
                    showPieChart ? 'Donut Chart' : 'Bar Chart',
                    style: TextStyle(
                      color: Color(0xFF9AA2C1),
                      fontSize: 12.0, // You can adjust the font size as needed
                    ),
                  ),
                  Transform.scale(
                    scale: 0.6,
                    child: CupertinoSwitch(
                      value: showPieChart,
                      activeColor: Color(0xFF647DF5),
                      onChanged: (newValue) {
                        setState(() {
                          showPieChart = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: showPieChart
                            ? BarChartSample(
                                userid: selectedManagerUserId,
                                defaultFromDate: defaultFromDate,
                                defaultToDate: defaultToDate,
                              )
                            : PieChartSample2(
                                userid: selectedManagerUserId,
                                defaultFromDate: defaultFromDate,
                                defaultToDate: defaultToDate,
                              )),
                  ),
                ],
              ),
              Flexible(
                flex: 4,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0))),
                      child: CustomDataTable(
                        searchFocusNode: _searchFocusNode,
                        searchController: _searchController,
                        columntitle: "Allocation %",
                        employeedetails: employeedetails,
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: Color(0xFF9AA2C1),
          onPressed: () async {
            showBottomSheet(context);
          },
          child: Icon(
            Icons.filter_list_alt,
            size: 25.0,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
