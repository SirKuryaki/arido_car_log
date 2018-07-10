import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Image.asset('res/ic_fills.png', width: 36.0),
        activeIcon: Image.asset('res/ic_fills_active.png', width: 36.0),
        title: Text(
          'Fills',
          style: TextStyle(color: Colors.red),
        ),
      ),
      BottomNavigationBarItem(
        icon: Image.asset('res/ic_maintenance.png', width: 36.0),
        activeIcon: Image.asset('res/ic_maintenance_active.png', width: 36.0),
        title: Text(
          'Maintenances',
          style: TextStyle(color: Colors.red),
        ),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Arido Car Log'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: items,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
