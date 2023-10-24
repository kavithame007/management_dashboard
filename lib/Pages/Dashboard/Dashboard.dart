import 'package:flutter/material.dart';
import 'package:management_dashboard/Common/App_Config.dart';
import 'package:management_dashboard/Widgets/customcard.dart';
import 'package:management_dashboard/Widgets/report_card.dart';
import 'package:management_dashboard/Widgets/WordCloud.dart';
import 'package:management_dashboard/Widgets/bottom_bar.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  bool isCustomerToggleOn = false;
  bool isWeeklySelected = false;
  bool isMonthlySelected = false;
  bool isLogged = false;
  Map<String, int> customerData = {
    'Flutter': 8,
    'Dart': 3,
    'Programming': 5,
    'Mobile': 7,
    'Web': 2,
    'Desktop': 4,
    'iOS': 5,
    'Android': 4,
    'Word': 5,
    'Cloud': 6,
    'Code': 4,
  };
  Map<String, int> projectData = {
    'Samsung': 6,
    'Intel': 5,
    'Tesla': 8,
    'AMD': 4,
    'Google': 6,
    'Qualcom': 3,
    'Netflix': 4,
    'Meta': 3,
    'Amazon': 4,
    'Rencata': 3,
    'Intranet': 2,
    'SmartCV': 6,
    'Vistapoint': 5
  };
  String userName = '';
  final AadOAuth oauth = new AadOAuth(AppConfiguration.config);

  Map<String, int> getWordCloudData() {
    return isCustomerToggleOn ? customerData : projectData;
  }

  void _showWeeklyBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Option 1 for Weekly'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Option 2 for Weekly'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
              ],
            ),
          );
        });
  }

  void _showMonthlyBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Option 1 for Monthly'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Option 2 for Monthly'),
                  onTap: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
                // Add more ListTiles for additional options
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getLocalInfo(); // Call a separate function to handle async operations.
  }

  getLocalInfo() async {
    SharedPreferences userContext = await SharedPreferences.getInstance();
    String inputString = userContext.getString('EmpName') ?? '';
    List<String> parts = inputString.split(' ');

    if (parts.length > 1) {
      String result = parts[0];
      userName = parts[0];
    } else {
      userName = inputString;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFDEEBFE),
        elevation: 0.0,
        title: Text("Welcome $userName",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            )),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.account_circle_rounded,
              color: Color(0xFF647DF5),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('ProfileSettings');
            },
          ),
          IconButton(
            padding: EdgeInsets.only(left: 0.0, right: 20.0),
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.expand_more,
              color: Color(0xFF9BA3C2),
            ),
            onPressed: () {
              //Navigator.of(context).pushReplacementNamed('ProfileSettings');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              InkWell(
                child: Container(
                  height: 95.0,
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                    color: Color(0xFF647DF5),
                    child: ListTile(
                      leading: Icon(
                        Icons.group,
                        color: Colors.white,
                        size: 55,
                      ),
                      title: Text(
                        "Team list with Allocation",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "By Manager & By project",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing:
                          Icon(Icons.chevron_right_sharp, color: Colors.white),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, 'TeamAllocation');
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10.0),
                child: Text("Timesheet Report",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    )),
              ),
              CustomCardList(),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10.0),
                child: Text("Other Report",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    )),
              ),
              ReportCards(),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10.0),
                child: Text("Project Time Entry",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          backgroundColor: isWeeklySelected
                              ? Color(0xFFDEEBFE)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(50), // radius of 50
                          ), // text (and icon) color
                        ),
                        onPressed: () {
                          setState(() {
                            isWeeklySelected = true;
                            isMonthlySelected = false;
                          });
                          _showWeeklyBottomSheet(context); // <-- Add this line
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Weekly',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isWeeklySelected
                                  ? Color(0xFF6880F5)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // space between buttons
                  Flexible(
                    child: Container(
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          backgroundColor: isMonthlySelected
                              ? Color(0xFFDEEBFE)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(60), // radius of 60
                          ), // text (and icon) color
                        ),
                        onPressed: () {
                          setState(() {
                            isWeeklySelected = false;
                            isMonthlySelected = true;
                          });
                          _showMonthlyBottomSheet(context); // <-- Add this line
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Monthly',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: isMonthlySelected
                                  ? Color(0xFF6880F5)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('Project'),
                  Switch(
                    value: isCustomerToggleOn,
                    onChanged: (newValue) {
                      setState(() {
                        isCustomerToggleOn = newValue;
                      });
                    },
                  ),
                  Text('Customer'),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: WordCloud(
                  data: getWordCloudData(),
                ),
              ),

// Container(
//   height:(MediaQuery.of(context).size.height).toDouble(), // Adjust the height as needed
//   child: WordCloudTapView(
//     data: WordCloudData(data: [ {'word': 'Apple', 'value': 100.0},
//       {'word': 'Samsung', 'value': 60.0},
//       {'word': 'Intel', 'value': 55.0},
//       {'word': 'Tesla', 'value': 50.0},
//       {'word': 'AMD', 'value': 40.0},
//       {'word': 'Google', 'value': 35.0},
//       {'word': 'Qualcom', 'value': 31.0},
//       {'word': 'Netflix', 'value': 27.0},
//       {'word': 'Meta', 'value': 27.0},
//       {'word': 'Amazon', 'value': 26.0},
//
//
//     ]), // Provide your data here
//     mapwidth: (MediaQuery.of(context).size.width).toInt(),
//     mapheight:200,
//     mintextsize: 20,
//     maxtextsize: 50,
//     attempt: 400,
//     shape: WordCloudCircle(radius: 1000), // Customize the shape
//     fontFamily: 'Arial', // Customize font properties
//     fontStyle: FontStyle.normal,
//     fontWeight: FontWeight.normal,
//     mapcolor: Colors.white, // Customize the background color
//     colorlist: [Colors.grey, Colors.grey, Colors.grey],
//     wordtap: WordCloudTap(), // Provide a WordCloudTap instance
//   ),
// ),
//
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
