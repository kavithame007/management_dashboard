import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:management_dashboard/Pages/Dashboard/Dashboard.dart';
import 'package:management_dashboard/Pages/Employement_Productivity/Employee_Productivity.dart';
import 'package:management_dashboard/Pages/Login/Login.dart';
import 'package:management_dashboard/Pages/Others/Profile.dart';
import 'package:management_dashboard/Pages/Others/SavedFilters.dart';
import 'package:management_dashboard/Pages/Others/Theme.dart';
import 'package:management_dashboard/Pages/Project_Allocation/Project_Allocation.dart';

import 'Pages/TimeSheet_Approval/Timesheet_Approval.dart';

void main() => runApp(const MyApp());

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Management Dashboard',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: Color(0xFFDEEBFE),
          bottomAppBarTheme: BottomAppBarTheme(
            color: Colors.black,
          ),
        ),
        navigatorKey: navigatorKey,
        initialRoute: 'Login',
        routes: {
          'Dashboard': (context) => Dashboard(),
          'TeamAllocation': (context) => Teamallocation_page(),
          'EmployeeProductivity': (context) => EmployeeProductivity(),
          'Login': (context) => LoginPage(),
          'ProfileSettings': (context) => ProfileSettings(),
          'ThemeSettings': (context) => ThemeSettings(),
          'SavedFilters': (context) => SavedFilters(),
          '///': (context) => timesheet_approval()
        });
  }
}
