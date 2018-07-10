import 'package:flutter/material.dart';

import 'cars/CarPage.dart';
import 'HomePage.dart';
import 'onboarding/OnboardingPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Arido\'s Car log',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),//(title: 'Car log'),
      routes: <String, WidgetBuilder>{
        ONBOARDING_PAGE_ROUTE: (BuildContext context) => OnboardingPage(),
        CAR_PAGE_ROUTE: (BuildContext context) => HomePage(),
      },
    );
  }
}
