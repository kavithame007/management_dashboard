import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:management_dashboard/API_Service/networking.dart';

class BarChartSample extends StatefulWidget {
  final userid;
  final defaultFromDate;
  final defaultToDate;

  BarChartSample({
    required this.userid,
    required this.defaultFromDate,
    required this.defaultToDate,
  });

  @override
  _BarChartSampleState createState() => _BarChartSampleState();
}

class _BarChartSampleState extends State<BarChartSample> {
  List<Map<String, dynamic>> projectData = [];
  Map<String, Color> projectColors = {};
  static const Color greyColor = Color(0xFF808080);
  int largestIndex = 0;

  @override
  void didUpdateWidget(BarChartSample oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.userid != oldWidget.userid ||
        widget.defaultFromDate != oldWidget.defaultFromDate ||
        widget.defaultToDate != oldWidget.defaultToDate) {
      fetchDataFromAPI(widget.userid);
    }
  }

  @override
  void initState() {
    super.initState();
    int userid = widget.userid;
    fetchDataFromAPI(userid);
  }

  void assignColorsToProjects(Map<String, Color> colors) {
    projectColors = colors;
  }

  Future<void> fetchDataFromAPI(userid) async {
    try {
      final response = await Networking.fetchData(
        apiUrl:
        'https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetProjectAllocationChart?-api',
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
        groupAndAggregateData();
        //determineLargestIndex();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

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

    final List<Map<String, dynamic>> aggregatedData = projectPercentages.entries
        .map((entry) => {
      "projectTask": entry.key,
      "percentage": entry.value,
    })
        .toList();

    setState(() {
      projectData = aggregatedData;
      assignColorsToProjects(projectColors);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height:5.0,
        ),
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(

            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                touchTooltipData:BarTouchTooltipData(
                    maxContentWidth:30,
                    tooltipPadding:EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    tooltipBgColor: Color(0xFFEFF5FE)
                ),
              ),

              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  reservedSize:30,
                  showTitles: true,
                  interval: 25,
                  getTitles: (value) {
                    return value.toInt().toString();
                  },
                ),
                bottomTitles: SideTitles(
                  showTitles:false,
                  //margin:10,
                ),
                rightTitles: SideTitles( // Add this part to hide right-side percentages
                  showTitles: false,
                ),
                topTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(
                  show: true,
                  border:Border(bottom:BorderSide(color:Color(0xFF9AA2C1),width:1.0,))
              ),
              barGroups: showingBarGroups(),


            ),

          ),
          // Set the desired width here
        ),

        SizedBox(
          height:5.0,
        ),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 0.0,
          runSpacing: -1,
          children: buildLegendWidgets(),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingBarGroups() {
    return List.generate(projectData.length, (index) {
      final projectTask = projectData[index]["projectTask"].toString();
      final rawPercentage = projectData[index]["percentage"].toDouble();
      final percentage = double.parse(rawPercentage.toStringAsFixed(1));
      final color = projectColors[projectTask] ?? getRandomColor();


      return BarChartGroupData(

        x: index,
        barRods: [
          BarChartRodData(
            y: percentage,
            colors: [color],
            width: 15,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
            ),




          ),


        ],

        showingTooltipIndicators: [0],
      );
    });
  }

  List<Widget> buildLegendWidgets() {
    return projectData.map((data) {
      final projectTask = data["projectTask"].toString();
      final color = projectColors[projectTask] ?? getRandomColor();

      return Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
        backgroundColor: Color(0xFFEFF5FE),
        avatar: CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        label: Text(
          projectTask,
          style: TextStyle(fontSize: 10),
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