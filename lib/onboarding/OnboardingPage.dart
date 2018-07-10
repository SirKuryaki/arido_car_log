import 'package:flutter/material.dart';
import 'package:circle_indicator/circle_indicator.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../service/UserService.dart';

const String ONBOARDING_PAGE_ROUTE = "/onboarding";

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final UserService _userService = UserService.instance;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: <Widget>[
            PageView(
              controller: _controller,
              children: <Widget>[
                _getOnboardingStepPage(context, 'res/bkg_onboarding.webp',
                    'Welcome to Arido\'s Car log'),
                _getOnboardingStepPage(context, 'res/bkg_onboarding.webp',
                    'Track your fuel consumptions'),
                _getOnboardingStepPage(context, 'res/bkg_onboarding.webp',
                    'Keep control of your maintenances'),
                _getLoginStepPage(context)
              ],
            ),
            Positioned(
              bottom: 20.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: CircleIndicator(
                    _controller, 4, 5.0, Colors.white70, Colors.white),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getOnboardingStepPage(
      BuildContext context, String image, String text) {
    return Stack(
      children: <Widget>[
        Image.asset(
          image,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getLoginStepPage(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          'res/bkg_onboarding.webp',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Continue with your Google account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
              RaisedButton(
                color: Colors.indigo,
                onPressed: _loginUser,
                child: Text('Log in', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _loginUser() async {
    final FirebaseUser user = await _userService.getFirebaseUser();
    if (user == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('Error'),
                content: Text('Couldn\'t login, please try again'),
              ));
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
}
