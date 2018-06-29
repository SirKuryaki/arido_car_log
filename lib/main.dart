import 'package:flutter/material.dart';

import 'service/UserService.dart';
import 'model/Car.dart';
import 'cars/CarPage.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(new MyApp());

FirebaseUser _user;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Arido\'s Car log',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new WelcomePage(title: 'Car log'),
      routes: <String, WidgetBuilder>{
        CAR_PAGE_ROUTE: (BuildContext context) => CarPage(),
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WelcomePageState createState() => new _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final UserService _userService = UserService.instance;

  String _status;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loginUser();
  }

  _loginUser() async {
    setState(() {
      _status = "Loading...";
    });
    final FirebaseUser user = await _userService.getFirebaseUser();
    if (user == null) {
      setState(() {
        _user = null;
        _status = "Couldn\'t login, please try again";
        _hasError = true;
      });
      return;
    }

    setState(() {
      _user = user;
      _status = "Hi ${user.displayName}";
    });

    List<Car> cars = await _userService.getMyCarList(user);
    if (cars == null) {
      setState(() {
        _status = "Error while retrieving info";
      });
    } else {
      setState(() {
        if (cars.length == 0) {
          _status = "No cars added!";
        } else {
          _status = cars.toString();
        }
      });
    }
  }

  _addCar() {
    Navigator.of(context).pushNamed(CAR_PAGE_ROUTE);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Welcome to Arido\'s Car Log:',
              style: new TextStyle(
                  fontSize: 18.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Merriweather"),
            ),
            new Text(
              '$_status',
              style: Theme.of(context).textTheme.body1,
            ),
            _hasError
                ? new Container(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: new RaisedButton(
                        color: Colors.red,
                        onPressed: _loginUser,
                        child: new Text("Retry",
                            style: new TextStyle(color: Colors.white))))
                : new Container(),
          ],
        ),
      ),
      floatingActionButton: _user == null
          ? null
          : FloatingActionButton(
              onPressed: _addCar,
              tooltip: 'Add Car',
              child: Icon(Icons.add),
            ),
    );
  }
}
