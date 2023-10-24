import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:management_dashboard/main.dart';

class AppConfiguration {
  static final Config config = Config(
      tenant: '7bf109b7-39a2-49d4-911d-09736db83214',
      clientId: 'b26ddf53-9bbe-4407-87f2-647c55400794',
      scope: 'openid profile offline_access',
      navigatorKey: navigatorKey,
      redirectUri: 'msauth://com.example.management_app/cs6RfY4RTpx2qUSvQjmmX4cGcFE%3D',
      loader: SizedBox()
  );
}