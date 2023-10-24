import 'package:flutter/material.dart';



class CustomCardList extends StatelessWidget {
  final List<CustomCardData> cardDataList = [
    CustomCardData(icon: Icons.home, text: 'Timesheet Entry', hours: 10),
    CustomCardData(icon: Icons.work, text: 'Timesheet Approval', hours: 8),
    CustomCardData(icon: Icons.school, text: 'Exceeding Allocation', hours: 6),
    CustomCardData(icon: Icons.shopping_cart, text: 'Non-split Hours', hours: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardDataList.map((data) => CustomCard(data)).toList(),
      ),
    );
  }
}

class CustomCardData {
  final IconData icon;
  final String text;
  final int hours;

  CustomCardData({required this.icon, required this.text, required this.hours});
}

class CustomCard extends StatelessWidget {
  final CustomCardData data;

  CustomCard(this.data);

  void _navigateToPage(BuildContext context) {
    if (data.text == 'Timesheet Entry') {
      Navigator.pushNamed(context,'//');

    } else if (data.text == 'Timesheet Approval') {
      Navigator.pushNamed(context,'///');

    }
    // Add similar conditions for other pages
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPage(context),
      child: Container(
        width: 100,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8.0, top: 8.0, bottom: 8.0),
                  child: Icon(data.icon, size: 48, color: Color(0xFF647DF5)),
                ),
                Text(data.text,
                    style: TextStyle(fontSize: 13, color: Colors.black,fontWeight: FontWeight.w500,)),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFFEFF5FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.hours} ',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Positioned(
              top: 32,
              right: 8,
              child: Text(
                'hours',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
