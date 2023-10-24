import 'package:flutter/material.dart';

class ReportCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomReportCard(
            color: Color(0xFFE94E73), // Change color as needed
            icon: Icons.business, // Suitable icon for non-productive & productive
            text: 'Productive & Non-Productive',
            routeName:'EmployeeProductivity',
          ),
          CustomReportCard(
            color: Color(0xFF53D7A8), // Change color as needed
            icon: Icons.money, // Suitable icon for billable & non-billable
            text: 'Billable & Non-Billable',
            routeName:'CustomReportCard'
          ),
          CustomReportCard(
            color: Colors.yellow.shade800, // Change color as needed
            icon: Icons.receipt, // Suitable icon for tax invoice
            text: 'Tax Invoice',
            routeName:'CustomReportCard'
          ),
        ],
      ),
    );
  }
}

class CustomReportCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final String routeName; // New property to store the route name

  CustomReportCard({
    required this.color,
    required this.icon,
    required this.text,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName); // Navigate to the specified route
      },
      child: Container(
        width: 200, // Change width as needed
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 48),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
