import 'package:flutter/material.dart';

import 'service/UserService.dart';
import 'onboarding/OnboardingPage.dart';
import 'cars/FillsPage.dart';
import 'cars/MaintenancesPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService.instance;
  final PageController _controller = PageController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkUserLogged();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _checkUserLogged() async {
    bool isLogged = await _userService.isLogged();
    if (!isLogged) {
      Navigator.of(context).pushReplacementNamed(ONBOARDING_PAGE_ROUTE);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Image.asset('res/ic_fills.png', width: 36.0),
        activeIcon: Image.asset('res/ic_fills_active.png', width: 36.0),
        title: Text(
          'Fills',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      BottomNavigationBarItem(
        icon: Image.asset('res/ic_maintenance.png', width: 36.0),
        activeIcon: Image.asset('res/ic_maintenance_active.png', width: 36.0),
        title: const Text(
          'Maintenances',
          style: const TextStyle(color: Colors.red),
        ),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arido Car Log'),
      ),
      body: PageView(
        children: [FillsPage(), MaintenancesPage()],
        controller: _controller,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: items,
        currentIndex: _currentIndex,
        onTap: (int index) {
          _controller.animateToPage(index,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
      ),
    );
  }
}
