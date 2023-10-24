import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../API_Service/networking.dart';

class PieChartSample2 extends StatefulWidget {
  final userid;
  final defaultFromDate;
  final defaultToDate;
  PieChartSample2({
    required this.userid,
    required this.defaultFromDate,
    required this.defaultToDate,
  });
  @override

  _PieChartSample2State createState() => _PieChartSample2State();
}

class _PieChartSample2State extends State<PieChartSample2> {
  Map<String, Color> projectColors = {};
  List<Map<String, dynamic>> projectData = []; // Store the API data here
  int largestIndex = 0;
  static const Color greyColor = Color(0xFF808080);



  @override
  void didUpdateWidget(PieChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userid != oldWidget.userid || widget.defaultFromDate  != oldWidget.defaultFromDate ||
        widget.defaultToDate != oldWidget.defaultToDate) {
      fetchDataFromAPI(widget.userid);
    }
  }
  @override
  void initState() {
    super.initState();
    int userid = widget.userid;
    //print(userid);

    fetchDataFromAPI(userid); // Fetch data when the widget initializes
  }
  void assignColorsToProjects() {
    for (int i = 0; i < projectData.length; i++) {
      final projectTask = projectData[i]["projectTask"].toString();
      if (!projectColors.containsKey(projectTask)) {
        projectColors[projectTask] = getRandomColor();
      }
    }
  }

  // Fetch data from the API
  Future<void> fetchDataFromAPI(userid) async {
    print(userid);
    try {
      final response = await Networking.fetchData(
        apiUrl: 'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetProjectAllocationChart?-api',
        headers: {
          'Content-Type': 'application/json',
        },
        requestBody: {
          "userID": widget.userid,
          "OrganizationId": 2,
          "Fromdate": widget.defaultFromDate,
          "ToDate": widget.defaultToDate,
        },
      );
      projectData = List<Map<String, dynamic>>.from(response);

      setState(() {
        projectData = List<Map<String, dynamic>>.from(response);
        groupAndAggregateData(); // Group data by project and calculate total percentage
        determineLargestIndex(); // Determine the project with the largest percentage
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Group data by project and calculate total percentage for each project
  void groupAndAggregateData() {
    final Map<String, double> projectPercentages = {};
    final Map<String, Color> projectColors = {};
    bool hasLessThanOnePercent = false; // Flag to track if there are projects with less than 1 percent

    for (final data in projectData) {
      final project = data["project"].toString();
      final percentage = data["percentage"].toDouble();
      projectPercentages[project] ??= 0;
      projectPercentages[project] = (projectPercentages[project]??0) + percentage;

      // Assign colors to each project
      if (!projectColors.containsKey(project)) {
        projectColors[project] = getRandomColor();
      }
    }

    // Check if any project has an overall percentage less than 1
    for (final entry in projectPercentages.entries) {
      if (entry.value < 1.0) {
        hasLessThanOnePercent = true;
        break;
      }
    }

    if (hasLessThanOnePercent) {
      // Combine projects with less than 1 percent into "Others"
      final List<String> projectsToRemove = [];
      double totalPercentageForOthers = 0;

      for (final entry in projectPercentages.entries) {
        final project = entry.key;
        final percentage = entry.value;

        if (percentage < 1.0) {
          projectsToRemove.add(project);
          totalPercentageForOthers += percentage;
        }
      }

      // Add the "Others" category with the total percentage
      projectPercentages["Others"] = totalPercentageForOthers;

      // Remove the combined projects from the map
      for (final projectToRemove in projectsToRemove) {
        projectPercentages.remove(projectToRemove);
      }
    }
    projectColors["Others"] = greyColor;


    // Create a new list of project data with aggregated percentages
    final List<Map<String, dynamic>> aggregatedData = projectPercentages.entries
        .map((entry) => {
      "projectTask": entry.key,
      "percentage": entry.value,
    })
        .toList();

    setState(() {
      projectData = aggregatedData;
      assignColorsToProjects();
    });
  }

  // Determine the project with the largest percentage
  void determineLargestIndex() {
    double largestPercentage = 0;
    int index = 0;

    for (int i = 0; i < projectData.length; i++) {
      final percentage = projectData[i]["percentage"].toDouble();
      if (percentage > largestPercentage) {
        largestPercentage = percentage;
        index = i;
      }
    }

    setState(() {
      largestIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.7,
          child: PieChart(
            PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: showingSections(),
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          spacing:0.0,
          runSpacing:-1,
          children: buildLegendWidgets(),
        ),

        //need legends for the pie chart with same color as presented in the pie chart
      ],
    );
  }
  List<Widget> buildLegendWidgets() {
    return projectData.map((data) {
      // final percentage = data["percentage"].toDouble();
      final projectTask = data["projectTask"].toString();
      final color = projectColors[projectTask] ?? getRandomColor();

      return Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
        //labelPadding: EdgeInsets.all(2.0),
        backgroundColor: Color(0xFFEFF5FE),
        avatar: CircleAvatar(
          radius: 6, // Adjust the radius as needed
          backgroundColor: color, // Set the background color
        ),
        label: Text(
          projectTask,
          style: TextStyle(fontSize: 10),
        ),
      );
    }).toList();
  }
  List<PieChartSectionData> showingSections() {
    return projectData.map((data) {
      final percentage = data["percentage"].toDouble();
      final projectTask = data["projectTask"].toString();

      final isLargest = projectData.indexOf(data) == largestIndex;
      final color = projectColors[projectTask] ?? getRandomColor();// Check if this project is the largest

      //final fontSize = isLargest ? 20.0 : 15.0;
      final radius = isLargest ? 60.0 : 50.0;
      double fontSize;
      if(percentage < 5)
      {
        fontSize = 8.0;
      }
      else{
        fontSize = isLargest ? 20.0 : 15.0;
      }
      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toInt()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color getRandomColor() {
    final random = Random();
    // Generate a random color excluding grey
    Color randomColor;
    do {
      randomColor = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1.0,
      );
    } while (randomColor == greyColor);
    return randomColor;
  }
}

// class Indicator extends StatelessWidget {
//   final Color color;
//   final String text;
//
//   const Indicator({
//     Key? key,
//     required this.color,
//     required this.text,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: color,
//           ),
//         ),
//         const SizedBox(
//           width: 4,
//         ),
//         Text(
//           text,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }