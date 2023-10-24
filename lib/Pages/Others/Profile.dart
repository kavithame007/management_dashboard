import 'package:aad_oauth/aad_oauth.dart';
import 'package:flutter/material.dart';
import 'package:management_dashboard/Pages/Others/SavedFilters.dart'; // Import the SavedFilter page
import 'package:management_dashboard/Pages/Others/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Common/App_Config.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _isSwitched = false;
  final AadOAuth oauth = new AadOAuth(AppConfiguration.config);
  bool isLogged = false;
  String userName = '';

  Future<bool> logout() async {
    await oauth.logout();
    var hasCachedAccountInformation = await oauth.hasCachedAccountInformation;
    if (hasCachedAccountInformation == null) {
      print('hasCachedAccountInformation $hasCachedAccountInformation');
      isLogged = false;
    }
    return isLogged;
  }

  @override
  void initState() {
    super.initState();
    getLocalInfo(); // Call a separate function to handle async operations.
  }

  getLocalInfo() async {
    SharedPreferences userContext = await SharedPreferences.getInstance();
    userName = userContext.getString('EmpName') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF5FE),
      appBar: AppBar(
        backgroundColor: Color(0xFFEFF5FE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black),
          onPressed: () {
            //Navigator.pop(context);
             //Navigator.pushNamed(context, routeName)
             Navigator.of(context).pushReplacementNamed('Dashboard');
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfile(
                userName: userName,
            ),
            SizedBox(height: 20),
            menuItem(Icons.pie_chart, 'Custom Dashboard'),
            menuItem(Icons.filter_alt, 'Saved Filter', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedFilters()),
              );
            }),
            menuItem(Icons.brush, 'Themes', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeSettings()),
              );
            }),

            menuItem(
              Icons.history,
              'Log Out',
              onTap: () async {
                var logged = await logout();
                if (!logged) {
                  print('Logged out');
                  Navigator.of(context).pushReplacementNamed('Login');
                }
              },
            ),
            Divider(color: Color(0xFFDEEBFE), thickness: 1.0),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Enable MPIN',
                      style: TextStyle(color: Color(0xFF9AA2C1), fontSize: 16),
                    ),
                    Switch(
                      value: _isSwitched,
                      onChanged: (value) {
                        setState(() {
                          _isSwitched = value;
                        });
                      },
                      activeColor: Color(0xFF647DF5),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    print("Update mPIN button clicked");
                  },
                  style: OutlinedButton.styleFrom(
                    primary: Color(0xFF647DF5), // Text color
                    side: BorderSide(color: Color(0xFF647DF5)), // Border color
                    backgroundColor: Colors.white,
                  ),
                  child: Text('Update mPIN'),
                ),
              ],
            ),
            // ... other contents, if needed ...
          ],
        ),
      ),
    );
  }

  Widget menuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFEFF5FE),
              child: Icon(icon, size: 20.0, color: Color(0xFF647DF5)),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(color: Color(0xFF0E142E), fontSize: 16)),
            ),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF5C658B), size: 16.0),
          ],
        ),
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  final String userName;

  UserProfile({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF647DF5),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 30.0, color: Color(0xFF647DF5)),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
