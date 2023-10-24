import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      child: BottomNavigationBar(

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded, color: Colors.grey),
            label: '',
            backgroundColor: Color(0XFFDEEBFE),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined, color: Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_rounded, color: Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.grey),
            label: '',
          ),
        ],
      ),
    );
  }
}
