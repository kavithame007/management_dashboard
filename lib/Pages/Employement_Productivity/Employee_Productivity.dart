import 'package:management_dashboard/Pages/Employement_Productivity/EmployeeProductivityFilter.dart';
import 'package:management_dashboard/Local_DB/repository.dart';
import 'package:management_dashboard/Widgets/Heatmap.dart';
import 'package:intl/intl.dart';
import 'package:management_dashboard/API_Service/networking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Local_DB/db_service.dart';

class EmployeeProductivity extends StatefulWidget {
  @override
  _EmployeeProductivity createState() => _EmployeeProductivity();
}

class _EmployeeProductivity extends State<EmployeeProductivity> {
  String LoggedUser = '';
  bool isWeekly = false;
  bool isEmployee = true;
  bool isEnabled = false;
  DateTime? _currentWeek;
  String? selectedManager = '76';
  String? selectedCustomer = '';
  String? selectedManagerName = '';
  String? selectedCustomerName = '';
  List<Map<String, dynamic>> savedFilters = [];
  List<dynamic> managerEmployee = [];
  List<String> managers = [];
  List<dynamic> customers = [];
  List<dynamic> customerEmployee = [];
  var _FilterService = FilterService();

  Future<void> fetch_manager_Data(empno) async {
    dynamic responseBody = await Networking.fetchData(
      apiUrl:
      'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetManagerHierarchy?reportingManagerCode=$empno',
      headers: {'Content-Type': 'application/json'},
      requestBody: {},
    );
    final managersdata = List<Map<String, dynamic>>.from(responseBody);
    setState(
          () {
        managers = managersdata
            .map<String>((manager) => manager['employeeName'])
            .toList();
      },
    );
  }

  List<String> getAvailableMonths(int year) {
    if (year == DateTime.now().year) {
      return months.sublist(0, DateTime.now().month);
    }
    return months;
  }

  Future<void> fetch_employee_Data(userid, fromDate, isWeekly) async {
    print('fetch_employee_Data($userid, $fromDate, $isWeekly)');
    managerEmployee = [];
    dynamic responseData = await Networking.fetchData(
      apiUrl:
      'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/EmployeeProductivity',
      headers: {
        'Content-Type': 'application/json',
      },
      requestBody: {
        "userID": userid,
        "OrganizationId": 2,
        "Fromdate": fromDate,
        "Interval": 6,
        "Mode": isWeekly,
        "Option": "employee",
        "TimeOff": 2
      },
    );
    setState(() {
      managerEmployee = responseData;
    });
  }

  Future<void> fetch_customer_Data(userid, fromDate) async {
    customers = [];
    dynamic responseData = await Networking.fetchData(
      apiUrl:
      'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetClientList',
      headers: {
        'Content-Type': 'application/json',
      },
      requestBody: {
        "userID": userid,
        "OrganizationId": 2,
        "Fromdate": fromDate,
        "Interval": 6,
        "Mode": 0,
        "Option": "employee",
        "TimeOff": 2
      },
    );
    setState(() {
      customers = responseData;
    });
  }

  Future<void> fetch_customeremployee_Data(
      userid, customerId, fromDate, isWeekly) async {
    customerEmployee = [];
    managerEmployee = [];
    dynamic responseData = await Networking.fetchData(
      apiUrl:
      'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/EmployeeProductivity',
      headers: {
        'Content-Type': 'application/json',
      },
      requestBody: {
        "userID": userid,
        "OrganizationId": 2,
        "Fromdate": fromDate,
        "Interval": 6,
        "Mode": isWeekly,
        "Option": "customer",
        "TimeOff": 2,
        "ProjectId": customerId,
      },
    );
    setState(() {
      customerEmployee = responseData;
      managerEmployee = responseData;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocalInfo();
  }

  getLocalInfo() async {
    SharedPreferences userContext = await SharedPreferences.getInstance();
    // LoggedUser = userContext.getString('EmpCode') ?? '76';
    LoggedUser = '76';
    print('LoggedUser $LoggedUser');
    selectedManagerName = userContext.getString('EmpName') ?? '';
    var currentDate = DateTime.now();
    var fromDate = DateTime(currentDate.year, currentDate.month - 5, 1);
    fetch_employee_Data(LoggedUser, fromDate.toString(), 1);
    if (currentStartMonth <= 0) {
      currentStartMonth += 12;
    }
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
                    selectedManager = filter['selectedManagerID'];
                    selectedCustomer = filter['selectedCustomerID'];
                    selectedManagerName = filter['selectedManagerName'];
                    selectedCustomerName = filter['selectedCustomerName'];
                    selectedYear = filter['selectedYear'];
                    currentStartMonth = filter['selectedMonth'];
                    isWeekly = filter['isWeekly'] == 1 ? true : false;
                    isEmployee = filter['isEmployee'] == 1 ? true : false;
                    _currentWeek = DateTime.parse(filter['selectedDate']);
                    var fromDate = isWeekly
                        ? _currentWeek
                        : DateTime(selectedYear, currentStartMonth, 1);
                    var endDate =
                    DateTime(selectedYear, currentStartMonth + 6, 1);
                    if (selectedYear != DateTime.now().year) {
                      if ((currentStartMonth + 6) != DateTime.now().month) {
                        isEnabled = true;
                      }
                    }
                    // print('selectedManager $selectedManager');
                    // print('selectedCustomer $selectedCustomer');
                    // print('selectedManagerName $selectedManagerName');
                    // print('selectedCustomerName $selectedCustomerName');
                    // print('selectedYear $selectedYear');
                    // print('currentStartMonth $currentStartMonth');
                    // print('isWeekly $isWeekly');
                    // print('isEmployee $isEmployee');
                    // print('_currentWeek $_currentWeek');
                    // print('fromDate $fromDate');

                    isEnabled = endDate == DateTime.now();
                    isEmployee
                        ? fetch_employee_Data(
                        selectedManager, fromDate.toString(), 1)
                        : fetch_customeremployee_Data(
                        selectedManager,
                        selectedCustomer,
                        fromDate.toString(),
                        (isWeekly ? 0 : 1));
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text('${filter['FilterName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ManagerName: ${filter['selectedManagerName']}'),
                        if (filter['isEmployee'] != 1)
                          Text('Customer: ${filter['selectedCustomerName']}'),
                        Text(
                            'isWeekly: ${filter['isWeekly'] == 0 ? 'Month' : 'Week'}'),
                        Text(
                            'Date: ${extractDate(filter['selectedDate'])}'), // Updated this line
                        Text('userID: ${filter['userID']}'),
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
              // This line adds the divider
            ),
          ),
        );
      },
    );
  }

  final TextEditingController managerController = TextEditingController();
  List<int> years =
  List.generate(DateTime.now().year - 1999, (index) => 2000 + index);

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
  int selectedYear = DateTime.now().year;
  int currentStartMonth = DateTime.now().month - 6;
  String selectedMonth = 'January';
  List<String> getMondays(int year, String month) {
    int monthIndex = months.indexOf(selectedMonth) + 1;

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

  List<String> displayedMonths = [];

  Widget _buildFilterInfo() {
    return GestureDetector(
      onTap: () {
        fetchData();
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Color(
            0xFFDEEBFE), // This sets the background color of the saved filters container
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Manager: ${selectedManagerName?.split(' ')[0] ?? 'N/A'}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C658B)),
              ),
            ),
            Expanded(
              child: Text(
                'Date: ${isWeekly ? _currentWeek != null ? DateFormat('dd MMM yyyy').format(_currentWeek!) : 'N/A' : '${months[currentStartMonth].substring(0, 3)} $selectedYear'}',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C658B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => EmployeeProductivityFilterLayout(
        onFilterChanged: (newSelectedManagerID,
            newSelectedManagerName,
            newSelectedCustomerID,
            newSelectedCustomerName,
            newSelectedYear,
            selectedMonth,
            currentWeek,
            isNewWeekly,
            isNewEmployee) {
          selectedManager = newSelectedManagerID;
          selectedCustomer = newSelectedCustomerID;
          selectedManagerName = newSelectedManagerName;
          selectedCustomerName = newSelectedCustomerName;
          var fromDate = isNewWeekly
              ? currentWeek
              : DateTime(newSelectedYear, selectedMonth + 1, 1);
          var endDate = DateTime(newSelectedYear, selectedMonth + 6, 1);
          if (newSelectedYear != DateTime.now().year) {
            if ((selectedMonth + 6) != DateTime.now().month) {
              isEnabled = true;
              print('isEnabled $isEnabled');
            }
          }
          isEnabled = endDate == DateTime.now();
          selectedYear = newSelectedYear;
          currentStartMonth = selectedMonth;
          isWeekly = isNewWeekly;
          isEmployee = isNewEmployee;
          _currentWeek = currentWeek;
          isNewEmployee
              ? fetch_employee_Data(selectedManager, fromDate.toString(), 1)
              : fetch_customeremployee_Data(selectedManager, selectedCustomer,
              fromDate.toString(), (isWeekly ? 0 : 1));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Employee Productivity",
          style: TextStyle(
            color: Colors.black,
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
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
      body: Column(
        children: [
          _buildFilterInfo(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    if (isWeekly) {
                      isEnabled = true;
                      _currentWeek = _currentWeek!.subtract(Duration(days: 7));
                    } else {
                      isEnabled = true;
                      currentStartMonth--;
                      if (currentStartMonth < 0) {
                        currentStartMonth = 11;
                        selectedYear--;
                      }
                    }
                  });
                  var fromDate = isWeekly
                      ? _currentWeek
                      : DateTime(selectedYear, currentStartMonth + 1, 1);
                  isEmployee
                      ? fetch_employee_Data(
                      selectedManager, fromDate.toString(), 1)
                      : fetch_customeremployee_Data(selectedManager,
                      selectedCustomer, fromDate.toString(), 1);
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                color: isEnabled ? Colors.black : Colors.grey,
                onPressed: isEnabled
                    ? () {
                  setState(() {
                    if (isWeekly) {
                      _currentWeek = _currentWeek!.add(Duration(days: 7));
                    } else {
                      currentStartMonth++;
                      if (selectedYear == DateTime.now().year) {
                        if ((currentStartMonth + 6) ==
                            DateTime.now().month) {
                          isEnabled = false;
                        }
                      }
                      if (currentStartMonth > 11) {
                        currentStartMonth -= 12;
                        selectedYear++;
                      }
                    }
                  });
                  var fromDate = isWeekly
                      ? _currentWeek
                      : DateTime(selectedYear, currentStartMonth + 1, 1);
                  isEmployee
                      ? fetch_employee_Data(
                      selectedManager, fromDate.toString(), 1)
                      : fetch_customeremployee_Data(selectedManager,
                      selectedCustomer, fromDate.toString(), 1);
                }
                    : null,
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: 5.0, bottom: 60.0), // Adjust the top padding here
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: managerEmployee.isNotEmpty
                              ? HeatMapGrid(
                            isWeekly: isWeekly,
                            isEmployee: isEmployee, // Add this line
                            selectedYear: selectedYear,
                            selectedMonth: selectedMonth,
                            currentWeek: _currentWeek,
                            currentStartMonth: currentStartMonth,
                            data: isEmployee
                                ? managerEmployee
                                : customerEmployee,
                          )
                              : CircularProgressIndicator(),
                        ),
                      ),
                      _buildLegend(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showBottomSheet();
                    },
                    child: Icon(Icons.filter_alt),
                    backgroundColor: Color(0xFF9AA2C1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    var get = await _FilterService.readEmployeeFilter();
    print('GetAll $get');
    savedFilters = get;
    _showSavedFilters();
  }

  Color _getGradientColor(double value) {
    if (value >= 0.75) return Color(0xFF52D7A8);
    if (value >= 0.61) return Color(0xFF8FE3C9);
    if (value >= 0.46) return Color(0xFFC0EDE4);
    if (value >= 0.36) return Color(0xFFEDC3D4);
    if (value >= 0.26) return Color(0xFFEA92A9);
    return Color(0xFFE94F73);
  }
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        color: Colors.white,  // Set the background color to white
        height: 110, // Adjust this height based on your requirement
        child: GridView.count(
          physics:
          NeverScrollableScrollPhysics(), // to prevent the GridView from scrolling
          crossAxisCount: 3,
          childAspectRatio: 2.5, // Adjust for your desired width vs. height
          children: <Widget>[
            _buildLegendItem(_getGradientColor(0.9), "75% to 100%"),
            _buildLegendItem(_getGradientColor(0.65), "61% to 74%"),
            _buildLegendItem(_getGradientColor(0.5), "46% to 60%"),
            _buildLegendItem(_getGradientColor(0.2), "< 25%"),
            _buildLegendItem(_getGradientColor(0.3), "26% to 35%"),
            _buildLegendItem(_getGradientColor(0.4), "36% to 45%"),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Use only required space
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5),
        Flexible(
            child: Text(label)), // Flexible ensures text respects boundaries
      ],
    );
  }
}
