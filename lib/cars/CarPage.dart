import 'package:flutter/material.dart';
import '../model/Car.dart';
import '../service/UserService.dart';

const String CAR_PAGE_ROUTE = "/car";

class CarPage extends StatefulWidget {
  @override
  _CarPageState createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showErrors = false;
  Car _car = Car();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add car'),
      ),
      body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            autovalidate: true,
            key: this._formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Mandatory';
                    }
                  },
                  onSaved: (String value) {
                    this._car.brand = value;
                  },
                  decoration: InputDecoration(
                      hintText: 'Hyundai', labelText: 'Car make'),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Roboto'),
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Mandatory';
                    }
                  },
                  onSaved: (String value) {
                    this._car.model = value;
                  },
                  decoration: InputDecoration(
                      hintText: 'Genesis coupe', labelText: 'Model'),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Roboto'),
                ),
                TextFormField(
                  validator: (value) {
                    var odometer = int.tryParse(value);
                    if (!(odometer is int)) {
                      return 'Invalid value';
                    }
                  },
                  initialValue: '0',
                  onSaved: (String value) {
                    this._car.initialOdometer = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Current odometer'),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Roboto'),
                ),
                InputDecorator(
                  decoration: InputDecoration(
                      labelText: 'Fuel type',
                      errorText: _showErrors && _car.fuelType == null
                          ? 'Required'
                          : null),
                  isEmpty: _car.fuelType == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      onChanged: (String value) {
                        setState(() {
                          _car.fuelType = value;
                        });
                      },
                      value: _car.fuelType,
                      isDense: true,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: const Color(0xFF202020),
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Roboto'),
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(
                            value: 'Gasoline', child: const Text('Gasoline')),
                        const DropdownMenuItem<String>(
                            value: 'Diesel', child: const Text('Diesel')),
                        const DropdownMenuItem<String>(
                            value: 'Hybrid', child: const Text('Hybrid')),
                        const DropdownMenuItem<String>(
                            value: 'CNG', child: const Text('CNG')),
                      ],
                    ),
                  ),
                ),
                InputDecorator(
                  decoration: InputDecoration(
                      labelText: 'Odometer in',
                      errorText: _showErrors && _car.measureUnit == null
                          ? 'Required'
                          : null),
                  isEmpty: _car.measureUnit == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      onChanged: (String value) {
                        setState(() {
                          _car.measureUnit = value;
                        });
                      },
                      value: _car.measureUnit,
                      isDense: true,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: const Color(0xFF202020),
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Roboto'),
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(
                            value: 'Miles', child: const Text('Miles')),
                        const DropdownMenuItem<String>(
                            value: 'Kilometers',
                            child: const Text('Kilometers')),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: screenSize.width,
                  child: RaisedButton(
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => this._addNewCar(),
                    color: Colors.redAccent,
                  ),
                  margin: EdgeInsets.only(top: 20.0),
                )
                // We will add fields here.
              ],
            ),
          )),
    );
  }

  void _addNewCar() {
    if (_formKey.currentState.validate() &&
        _car.measureUnit != null &&
        _car.fuelType != null) {
      _formKey.currentState.save();

      UserService.instance.saveCar(_car);
    } else {
      setState(() {
        _showErrors = true;
      });
    }
  }
}
