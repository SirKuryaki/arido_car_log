import 'package:flutter/material.dart';

import '../service/UserService.dart';

class FillsPage extends StatefulWidget {
  @override
  _FillsPageState createState() => _FillsPageState();
}

class _FillsPageState extends State<FillsPage> {
  final UserService _userService = UserService.instance;

  @override
  Widget build(BuildContext context) {
    return Center(child: new Text('Fills: Work in progress'));
  }
}
