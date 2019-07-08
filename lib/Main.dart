import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squaad/pages/BottomNavigationView.dart';
import 'package:squaad/pages/AuthPage.dart';
import 'package:squaad/pages/EditProfilePage.dart';
import 'package:squaad/pages/SettingsPage.dart';

Future<void> main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'Squaad',
    options: const FirebaseOptions(
      googleAppID: '1:1041885718204:android:75928b7e46307d03',
      gcmSenderID: '104188571820',
      apiKey: 'AIzaSyAJl6Fj-EwvskhGUbAeOC6WBD_-qxSULW8',
      projectID: 'squaad-id',
    ),
  );
  try {
    await Firestore(app: app).settings(timestampsInSnapshotsEnabled: true);
  } catch (Exception) {print("Failed to Set Firebase Settings: "+Exception.toString());}
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics())
        ],
        home: AuthPage(silentSignIn: true),
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.redAccent.shade700,
          accentColorBrightness: Brightness.light,
        ),
        routes: <String, WidgetBuilder>{
          '/AuthRoute': (BuildContext context) => AuthPage(),
          '/MainRoute': (BuildContext context) => BottomNavigationView(),
          '/SettingsRoute': (BuildContext context) => SettingsPage(),
          '/EditProfileRoute': (BuildContext context) => EditProfilePage(),
        });
  }
}
