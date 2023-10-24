import 'package:flutter/material.dart';

class ThemeSettings extends StatefulWidget {
  @override
  _ThemeSettings createState() => _ThemeSettings();
}

class _ThemeSettings extends State<ThemeSettings> {
  String? selectedTheme; // This variable will store the currently selected theme

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF5FE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Color(0xFF5C658B)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Themes',
          style: TextStyle(color: Color(0xFF0E142E)),
        ),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.account_circle_rounded,
              color: Color(0xFF647DF5),
            ),
            onPressed: () {},
          ),
          IconButton(
            padding: EdgeInsets.only(left: 0.0, right: 20.0),
            constraints: BoxConstraints(),
            icon: Icon(
              Icons.expand_more,
              color: Color(0xFF9BA3C2),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('ProfileSettings');
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Theme',
              style: TextStyle(color: Color(0xFF5C658B), fontSize: 18),
            ),
            SizedBox(height: 20),
            themeOption("Blue", Color(0xFF647DF5)),
            themeOption("Green", Color(0xFF53D7A8)),
            themeOption("Yellow", Color(0xFFF8C345)),
          ],
        ),
      ),
    );
  }

  Widget themeOption(String themeName, Color iconColor) {
    bool isSelected = themeName == selectedTheme;
    Color borderColor = isSelected ? Color(0xFF647DF5) : Colors.transparent;  // Determines the border color based on selection

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = themeName;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),  // Set border around the entire label content
            borderRadius: BorderRadius.circular(4),  // optional, if you want rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),  // Adding some padding inside the border
            child: Row(
              children: [
                // The outer circle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF5C658B), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    // The inner circle will only be visible if isSelected is true
                    child: isSelected
                        ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(0xFF647DF5),
                        shape: BoxShape.circle,
                      ),
                    )
                        : null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(themeName, style: TextStyle(color: Color(0xFF0E142E), fontSize: 16)),
                ),
                Icon(Icons.pie_chart, color: iconColor),
                SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

}