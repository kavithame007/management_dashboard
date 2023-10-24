
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_dashboard/API_Service/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:management_dashboard/Widgets/custom_timesheet_datatable.dart';
import '../../Local_DB/db_service.dart';
import '../../Local_DB/repository.dart';
import '../../Widgets/bottom_bar.dart';
import '../TimeSheet_Approval/Timesheet_Model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class timesheet_approval extends StatefulWidget {
  const timesheet_approval({super.key});

  @override
  State<timesheet_approval> createState() => _timesheet_approvalState();
}

class _timesheet_approvalState extends State<timesheet_approval> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  String LoggedUser = '';
  String? selectedManager = '76';
  String? selectedManagerName = 'Pavithra Laksmipathy';
  String defaultFromDate = "2023-08-13";
  String defaultToDate = "2023-08-19";
  TextEditingController filterNameController = TextEditingController();
  String? validationMessage;
  List<String> managers = [];
  List<int> user_id_manager = [];
  int organizationId = 2;
  List<Map<String, dynamic>> savedFilters = [];
  var _FilterService = FilterService();
  final TextEditingController managerController = TextEditingController();
  final TextEditingController WeekController = TextEditingController();
  List<String> months = [];
  /*
    '17-09-2023 to 23-09-2023',
    '24-09-2023 to 30-09-2023',
    '27-08-2023 to 02-09-2023',
    '03-09-2023 to 09-09-2023',
    '06-08-2023 to 12-08-2023',
    '13-08-2023 to 19-08-2023',
    '16-07-2023 to 22-07-2023',
    '23-07-2023 to 29-07-2023',
    '25-06-2023 to 01-07-2023',
    '02-07-2023 to 08-07-2023',
    '28-05-2023 to 03-06-2023',
    '04-06-2023 to 10-06-2023',
    '30-04-2023 to 06-05-2023',
    '07-05-2023 to 13-05-2023',
    '26-03-2023 to 01-04-2023',
    '02-04-2023 to 08-04-2023',
    '26-02-2023 to 04-03-2023',
    '05-03-2023 to 11-03-2023',
    '29-01-2023 to 04-02-2023',
    '05-02-2023 to 11-02-2023'
  ];*/
  String selectedWeek = '05-02-2023 to 11-02-2023';
  List<dynamic> employeedetails = [];
  final apiUrl = 'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetTimesheetApprovalStatus?';
  final headers = {
    'Content-Type': 'application/json',

  };
  int selectedManagerUserId = 76;
  Map<String, dynamic> get requestBody {
    return {
      "userID": selectedManagerUserId,
      "OrganizationId": organizationId,
      "Fromdate": defaultFromDate,//"2023-08-13",
      "ToDate": defaultToDate//"2023-08-19"
    };
  }
  int Userid_selectedManager = 0;
  //String filter_query = 'Weekly, start date =07/03/23; Manager=All';
  int UserId = 1680;

  void getSixMonthsWeekRanges() {
    months = generateLastSixMonthsWeekRanges();
    months = months.reversed.toList();
  }

  List<String> generateLastSixMonthsWeekRanges() {
    List<String> sixMonthsWeekRanges = [];
    var dateFormat = DateFormat("dd-MM-yyyy");
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 26; i++) { // 26 weeks for the last 6 months
      DateTime startDate = currentDate.subtract(Duration(days: currentDate.weekday - 1));
      DateTime endDate = currentDate.add(Duration(days: 7 - currentDate.weekday));
      sixMonthsWeekRanges.add(dateFormat.format(startDate) + ' to ' + dateFormat.format(endDate));
      currentDate = startDate.subtract(Duration(days: 1));
    }
    return sixMonthsWeekRanges.reversed.toList();
  }

  void initState() {
    super.initState();
    fetchcountData(selectedManagerUserId, defaultFromDate, defaultToDate);
    fetch_manager_Data(null);
    fetch_employee_Data(selectedManagerUserId, defaultFromDate, defaultToDate);
    getSixMonthsWeekRanges();
  }

  void fetchData(String s,userid, defaultFromDate, defaultToDate) async {
    dynamic responseData = await Networking.fetchData(
      apiUrl: apiUrl,
      headers: headers,
      requestBody: {
        "userID": userid,
        "OrganizationId": organizationId,
        "Fromdate": defaultFromDate,//"2023-08-01",
        "ToDate": defaultToDate//"2023-08-31"
      },);
    employeedetails = responseData;
    s == "Users" ? employeedetails :
    employeedetails = employeedetails
        .where((employee) => employee["status"] == s)
        .toList();
    print("Tapped on $s");

    setState(() {}); // Update the UI
  }
  //to get cound of the cards
  List<dynamic> employeecountdetails = [];
  final apicountUrl = 'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetTimesheetApprovalStatus?';

  void fetchcountData(userid, defaultFromDate, defaultToDate) async {
    print(defaultFromDate);
    print(defaultToDate);
    dynamic responseData = await Networking.fetchData(
      apiUrl: apicountUrl,
      headers: headers,
      requestBody: {
        "userID": userid,
        "OrganizationId": organizationId,
        "Fromdate": defaultFromDate,//"2023-08-01",
        "ToDate": defaultToDate//"2023-08-31"
      },);
    employeecountdetails = responseData;
    setState(() {}); // Update the UI
  }

  void showManagerList(BuildContext context,
      TextEditingController managerController,managers) {
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
                        setState(() {
                          filteredManagers = managers.where((manager) =>
                          manager.toLowerCase().contains(
                              value.toLowerCase()) ? true : false ).toList();

                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
// This is the icon next to the search bar
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
                          selectedManagerUserId = user_id_manager[index];
                          selectedManager =selectedManagerUserId.toString();
                          print(selectedManagerUserId);
                          selectedManagerName = filteredManagers[index];
                          //fetch_employee_Data(selectedManagerUserId, defaultFromDate, defaultToDate);


                          // selected member
                          Navigator.pop(context);
                        }
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
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
                        onTap: () {print("managers");
                        print(managers);
                        showManagerList(context, managerController,managers);
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
                              hintText: 'Select Manager',
                              hintStyle: TextStyle(color: Color(0xFF9AA2C1)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF9AA2C1)),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {print("Weeklist");
                        print(managers);
                        showWeekList(context, WeekController, months);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFFDEEBFE)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextField(
                            controller: WeekController,
                            enabled: false, // Disable editing
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Select Week',
                              hintStyle: TextStyle(color: Color(0xFF9AA2C1)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF9AA2C1)),
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
                                  padding: EdgeInsets.symmetric(horizontal: 5.0), // Add some padding to separate from adjacent widgets
                                  child: TextField(
                                    controller: filterNameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),  // This will make the TextField rounded
                                        borderSide: BorderSide.none,  // This will hide the default border
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,// This will fill the TextField with white color
                                      //hintText: 'Enter text...',
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await fetchData_db();
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
                                //savefilter();
                                List<String> dateParts = selectedWeek.split(' to ');
                                String defaultFromDate = formatDate(dateParts[0]);
                                String defaultToDate = formatDate(dateParts[1]);
                                fetch_employee_Data(selectedManagerUserId, defaultFromDate, defaultToDate);
                                fetchcountData(selectedManagerUserId, defaultFromDate, defaultToDate);
                                Navigator.pop(context);
                              },
                              child: Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              );
            },
          );
        });
  }

  void fetch_employee_Data(userid, defaultFromDate, defaultToDate) async {
    print("defaultFromDatedefaultToDate");
    print(defaultFromDate);
    print(defaultToDate);
    clickedCardIndex = 3;
   // SharedPreferences userContext = await SharedPreferences.getInstance();
   // LoggedUser = userContext.getString('UserCode') ?? '';
    print("hi");
    print(userid);
    dynamic responseData = await Networking.fetchData(
      apiUrl: 'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetTimesheetApprovalStatus',
      headers: {
        'Content-Type': 'application/json',
      },
      requestBody: {
        "userID": userid,
        "OrganizationId": organizationId,
        "Fromdate": defaultFromDate,//"2023-08-01",
        "ToDate": defaultToDate//"2023-08-31"
      },);

    employeedetails = await responseData;
    employeedetails = employeedetails
        .where((employee) => employee["status"] == "Submitted For Approval")
        .toList();
    setState(() {}); // Update the UI
  }

  Future<int> fetch_manager_Data(empno) async {
    dynamic responseBody = await Networking.fetchData(
      apiUrl:'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetManagerHierarchy?reportingManagerCode=$empno' ,//${login_details().Empno}
      headers:{ 'Content-Type' : 'application/json'},
      requestBody: {},);
    final managerData = List<Map<String, dynamic>>.from(responseBody);
    Map<String, dynamic> firstItem = managerData[0];
    managerData.sublist(1).sort((a, b) =>
        a['employeeName'].compareTo(b['employeeName']));
    managerData[0] = firstItem;
    print(managerData);
    setState(() {
      managers = managerData.map<String>((manager) => manager['employeeName']).toList();
      user_id_manager =  managerData.map<int>((manager) => manager['userId']).toList();
      if (managers.isNotEmpty) {
        //selectedManager = managers[0]; // Set default selection
        Userid_selectedManager = managerData[0]['userId']; // Set default userIdSelectedManager
      } else {
        selectedManager = 'Select Manager';
        Userid_selectedManager = 0; // No managers available, so set to empty
      }
      print(Userid_selectedManager);

    });// Update the UI
    return Userid_selectedManager;
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
          "Timesheet Approval",
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
            onPressed: () {},
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.expand_more,
              color: Color(0xFF9BA3C2),
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [Column(
          children: [
            GestureDetector(
              onTap: () {
                fetchData1();
              },
              child: ColoredBox(
                color: Color(0XFFDEEBFE),
                child: Row(
                  children: [
                    Text(
                      "Select Manager: $selectedManagerName" ,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Client Container
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.4,
                children: <Widget>[
                  cardWidget('Users', getItemValue('Users'), Color(0xFF647DF5),
                      Icons.person_2_sharp, "Users",0),
                  cardWidget(' Approved', getItemValue('Client Approved'),
                      Color(0xFF53D7A8), Icons.assignment_turned_in, "Client Approved",1),
                  cardWidget('Not Submitted', getItemValue('Submitted'),
                      Color(0xFFE94E73), Icons.cancel, "Submitted",2),
                  cardWidget('Submitted for Approval',
                      getItemValue('Submitted For Approval'),
                      Color(0xFFF8C345), Icons.check_box, "Submitted For Approval",3)
                ],
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))

                    ),

                    child: CustomDataTable(
                      searchFocusNode: _searchFocusNode,
                      searchController: _searchController,
                      columntitle: "Status",
                      employeedetails: employeedetails,
                    ),
                  )
              ), // Using the customized CustomDataTable widget
            ),
          ],
        ),
          Positioned(
            bottom: 1.0,
            // Adjust this value to change the button's vertical position
            right: 20.0,
            // Adjust this value to change the button's horizontal position
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.10,
              // Adjust the width and height as needed for your circle
              height: MediaQuery
                  .of(context)
                  .size
                  .width * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF9AA2C1), // Your desired background color
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list_alt,
                    size: 25.0,
                    color: Colors.white, // Set the icon color to white
                  ),
                  onPressed: () async {
                    _showBottomSheet(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  // Function to get the "itemValue" for a given "itemName"
  int getItemValue(String itemName) {
    for (var item in employeecountdetails) {
      if (item['listProjectApprovalStatus'] != null) {
        var projectApprovalStatusList = item['listProjectApprovalStatus'];
        for (var status in projectApprovalStatusList) {
          if (status['itemName'] == itemName) {
            return status['itemValue'];
          }
        }
      }
    }
    return 0; // Return 0 if not found
  }

  int clickedCardIndex = 3; // Initialize with -1 to indicate no card is initially clicked

  Future<void> fetchData1() async {
    var get = await _FilterService.readTimesheetFilter();
    savedFilters = get;
    _showSavedFilters();
  }


  Widget cardWidget(String title, int count, Color color, IconData icon, String subtitle, int index) {
    String formattedText = '$count ${title.toLowerCase()}';

    return InkWell(
      onTap: () {
        setState(() {
          clickedCardIndex = index;
        });
        List<String> dateParts = selectedWeek.split(' to ');
        String defaultFromDate = formatDate(dateParts[0]);
        String defaultToDate = formatDate(dateParts[1]);
        print(defaultFromDate);
        print(defaultToDate);
        fetchData("$subtitle", selectedManagerUserId, defaultFromDate, defaultToDate);
      },
      child: Card(
        color: color,
        elevation: index == clickedCardIndex ? 16 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          margin: EdgeInsets.all(11.0),

          decoration: index == clickedCardIndex ?BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2.0),
          ) :  BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 0), // Add an inner border
          ),
          child: SingleChildScrollView( // Wrap your content with SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: Colors.white, size: 42.0),
                SizedBox(height: 10.0),
                Text(
                  formattedText,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: index == clickedCardIndex ?Colors.white : Colors.transparent,
                  size: 24.0,
                ),
                // Add any additional content here
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showSavedFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            mainAxisSize:MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Saved Filters",
                  //textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF5C658B),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  )),
              Divider(
                color: Color(0xFFDEEBFE),
                thickness: 2,
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0XffEFF5FE),),
              color: Color(0xffEFF5FE),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: savedFilters.length,
                    itemBuilder: (context, index) {
                      final filter = savedFilters[index];
                      return InkWell(/*Dismissible(
                          key: Key(filter['id'].toString()), // Unique key for each item
                      onDismissed: (DismissDirection direction) async {
                      var repos = Repository();
                      var table = "TimesheetFilter";
                      var data = await repos.deleteDataByID(table, filter['id']);
                      if (data == 1) {
                      savedFilters.removeAt(index);
                      setState(() {
                      savedFilters;
                      });
                      }
                      },
                      background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(16),
                      child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      ),
                      ),
                      child: GestureDetector(*/
                        onTap: () {
                          selectedManagerName = filter['selectedManagerName'];
                          selectedManagerUserId =
                              int.parse(filter['selectedManagerID']);
                          selectedWeek = filter['selectedWeek'];
                          List<String> dateParts = selectedWeek.split(' to ');
                          String defaultFromDate = formatDate(dateParts[0]);
                          String defaultToDate = formatDate(dateParts[1]);
                          print(defaultFromDate);
                          print(defaultToDate);
                          print(selectedManagerUserId);
                          fetchcountData(selectedManagerUserId, defaultFromDate, defaultToDate);
                          fetch_employee_Data(
                              selectedManagerUserId, defaultFromDate, defaultToDate);
                          Navigator.pop(context);
                        },
                        child: ListTile(
                          title: Text(
                            '${filter['FilterName']}',
                            style: TextStyle(
                              color: Color(0xff0E142E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${filter['selectedManagerName']}',
                                  style: TextStyle(
                                    color: Color(0xff9AA2C1),
                                  )),
                            Text('ManagerName: ${filter['selectedManagerName']}'),
                            Text(
                                '${filter['selectedWeek']}'),
                            Text('userID: ${filter['UserID']}'),
                              //Text('userID: ${filter['UserID']}'),
                              Divider(
                                color: Color(0XFFDEEBFE),
                                thickness: 2,
                              ),
                            ],
                          ),
                          // trailing: IconButton(
                          //   icon: Icon(Icons.delete),
                          //   onPressed: () async {
                          //     var repos = Repository();
                          //     var table = "TimesheetFilter";
                          //     var data =
                          //         await repos.deleteDataByID(table, filter['id']);
                          //     if (data == 1) {
                          //       savedFilters.removeAt(index);
                          //       setState(() {
                          //         savedFilters;
                          //       });
                          //     }
                          //   },
                          // ),
                        ),
                      //),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 /* void _showSavedFilters() {
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
                    selectedManagerName = filter['selectedManagerName'];
                    selectedManagerUserId =
                        int.parse(filter['selectedManagerID']);
                    selectedWeek = filter['selectedWeek'];
                    List<String> dateParts = selectedWeek.split(' to ');
                    String defaultFromDate = formatDate(dateParts[0]);
                    String defaultToDate = formatDate(dateParts[1]);
                    print(defaultFromDate);
                    print(defaultToDate);
                    print(selectedManagerUserId);
                    fetchcountData(selectedManagerUserId, defaultFromDate, defaultToDate);
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
                            '${filter['selectedWeek']}'),
                        Text('userID: ${filter['UserID']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        var repos = Repository();
                        var table = "TimesheetFilter";
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
*/
  void showWeekList(BuildContext context,
      TextEditingController WeekController,months) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredWeek = months;

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
                        setState(() {
                          //filteredManagers = managers.where((manager) =>
                          //manager.toLowerCase().contains(
                          // value.toLowerCase()) ? true : false ).toList();

                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
// This is the icon next to the search bar
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: filteredWeek.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(filteredWeek[index]),
                        onTap: () {
                          WeekController.text = filteredWeek[index];
                          selectedWeek =filteredWeek[index];
                          //selectedManagerUserId = user_id_manager[index];
                          //fetch_employee_Data(selectedManagerUserId);


                          // selected member
                          Navigator.pop(context);
                        }
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
  var _TimesheetFilterService = FilterService();
  Future<void> fetchData_db() async {
    SharedPreferences userContext = await SharedPreferences.getInstance();
    LoggedUser = userContext.getString('UserCode') ?? '';
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

    var filter = TimesheetApprovalFilter();//EmployeeProductivityFilter(); //fetch_employee_Data(selectedManagerUserId, defaultFromDate, defaultToDate);
    filter.selectedManagerID = selectedManager;
    filter.selectedManagerName = selectedManagerName;
    filter.selectedWeek = selectedWeek;
    //filter.isEmployee = isEmployee;
    filter.userID = LoggedUser;
    filter.filterName = filterNameController.text;

    var result = await _TimesheetFilterService.saveTimesheetFilter(filter);
    print('Database $result');

    var get = await _TimesheetFilterService.readTimesheetFilter();
    print('GetAll $get');
  }

  String formatDate(String date) {
    DateTime dateTime = DateFormat('dd-MM-yyyy').parse(date);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

}



