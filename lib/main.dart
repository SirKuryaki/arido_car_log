import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

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
        _status = "Couldn\'t login, please try again";
        _hasError = true;
      });
      return;
    }

    setState(() {
      _status = "Hi ${user.displayName}";
    });
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
    );
  }
}
