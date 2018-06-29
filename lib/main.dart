import 'package:flutter/material.dart';
import 'model/Car.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cars/CarPage.dart';

void main() => runApp(new MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

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
  String _status;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loginUser();
  }

  Future<FirebaseUser> _getFirebaseUser() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signInSilently();
    if (googleUser == null) {
      googleUser = await _googleSignIn.signIn();
    }

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  _loginUser() async {
    setState(() {
      _status = "Loading...";
    });
    final FirebaseUser user = await _getFirebaseUser();
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

    List<Car> cars = await _getMyCarList(user);
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

  Future<List<Car>> _getMyCarList(FirebaseUser user) async {
    DocumentSnapshot doc =
        await Firestore.instance.collection("users").document(user.uid).get();
    if (doc == null || !doc.exists) {
      final DocumentReference ref =
          Firestore.instance.collection("users").document(user.uid);
      await ref.setData({"id": user.uid});
      doc = await ref.get();
    }

    final cars = await doc.reference.collection("cars").getDocuments();
    if (cars.documents.isEmpty) {
      return new List(0);
    }

    final carsArray = cars.documents;

    List<Car> carList = new List();
    for (final document in carsArray) {
      Car car = Car();
      car.id = document.data["id"] as String;
      car.brand = document.data["brand"] as String;
      car.model = document.data["model"] as String;
      car.version = document.data["version"] as String;
      car.year = document.data["year"] as int;
      carList.add(car);
    }

    return carList;
  }
}
