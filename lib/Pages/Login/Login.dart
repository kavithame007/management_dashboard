import 'package:flutter/material.dart';
import 'package:management_dashboard/Common/App_Config.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _UserCodeController = TextEditingController();
  bool isLogged = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AadOAuth oauth = new AadOAuth(AppConfiguration.config);
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initData(); // Call a separate function to handle async operations.
  }

  Future<void> _initData() async {
    var hasAccessToken = await oauth.hasCachedAccountInformation;

    if (hasAccessToken) {
      SharedPreferences userContext = await SharedPreferences.getInstance();
      String userCode = userContext.getString('EmpCode') ?? '';
      _UserCodeController.value = TextEditingValue(
        text: userCode,
        selection: TextSelection.fromPosition(
          TextPosition(offset: userCode.length),
        ),
      );
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, 'Dashboard');
      });
    }
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  Future<bool> login({required bool redirect, required String userId}) async {
    http.Response response;
    response = await http.get(Uri.parse(
        "https://sandstar-dev-api.azurewebsites.net/api/ManagementApp/GetAuthorizedManager?employeeCode=$userId"));

    if (response.body.isNotEmpty) {
      var data = json.decode(response.body);
      var isLoginEnabled = data[0]["isLoginEnabled"];

      if (response.statusCode == 200 && isLoginEnabled) {
        AppConfiguration.config.webUseRedirect = redirect;
        final result = await oauth.login();
        var accessToken = await oauth.getAccessToken();
        if (accessToken != null) {
          isLogged = true;
          SharedPreferences userContext = await SharedPreferences.getInstance();
          userContext.setString('EmpCode', data[0]["employeeCode"]);
          userContext.setString('UserCode', data[0]["userId"].toString());
          userContext.setString('EmpName', data[0]["employeeName"]);
          userContext.setString('accessToken', accessToken);
        }
      } else {
        var alert = AlertDialog(
            content: Text('You are not authorized'),
            actions: <Widget>[
              TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ]);
        showDialog(context: context, builder: (BuildContext context) => alert);
      }
    }
    return isLogged;
  }


  void hasCachedAccountInformation() async {
    var hasCachedAccountInformation = await oauth.hasCachedAccountInformation;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text('HasCachedAccountInformation: $hasCachedAccountInformation'),
      ),
    );
  }

  void logout() async {
    await oauth.logout();
    showMessage('Logged out');
  }

  String? _userCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'EmpCode is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Custom color half with curve
          Expanded(
            child: ClipPath(
              clipper: CurvedBottomClipper(),
              child: Container(
                color: Color(0xFF647DF5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/Group 121.png',
                          width: 100, height: 100),
                      SizedBox(height: 10.0),
                      Text(
                        'Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Login details half wrapped in SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 250,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: TextFormField(
                            controller: _UserCodeController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                suffixIcon: Icon(Icons.person),
                                labelText: 'EmpCode',
                                errorText: _errorText),
                            validator: _userCodeValidator,
                            onChanged: (value) {
                              setState(() {
                                _errorText = null;
                              });
                            },
                          )),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Color(0xFF647DF5)),
                          ),
                          onPressed: () async {
                            if (_UserCodeController.text != null &&
                                _UserCodeController.text.isNotEmpty) {
                              var logged = await login(
                                  userId: _UserCodeController.text,
                                  redirect: true);
                              if (logged) {
                                Future.delayed(Duration.zero, () {
                                  Navigator.pushReplacementNamed(context, 'Dashboard');
                                });
                              }
                            } else {
                              setState(() {
                                _errorText = _userCodeValidator(
                                    _UserCodeController.text);
                              });
                            }
                          },
                          // onPressed: _submitForm,
                          child: Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height - 30);

    var middle = size.width / 2;

    var firstControlPoint = Offset(middle / 2 - 50, size.height);
    var firstEndPoint = Offset(middle, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(middle + (middle / 2) + 50, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}