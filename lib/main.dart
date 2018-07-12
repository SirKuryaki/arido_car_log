import 'package:flutter/material.dart';

import 'cars/CarPage.dart';
import 'HomePage.dart';
import 'onboarding/OnboardingPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arido\'s Car log',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
      routes: {
        ONBOARDING_PAGE_ROUTE: (BuildContext context) => OnboardingPage(),
        CAR_PAGE_ROUTE: (BuildContext context) => CarPage(),
      },
    );
  }
}
