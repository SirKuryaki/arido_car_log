import 'package:flutter/material.dart';
import 'dart:async';

import '../service/UserService.dart';
import '../model/Fill.dart';
import '../model/Car.dart';

class FillPage extends StatefulWidget {
  @override
  _FillPageState createState() => _FillPageState();
}

class _FillPageState extends State<FillPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showErrors;
  Fill _fill;
  Car _car;
  List<Car> _myCars;
  final TextEditingController _odometerController =
      TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    _fill = Fill();
    _showErrors = false;
    _loadCars();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _fill.date,
        firstDate: DateTime(1950),
        lastDate: DateTime.now());

    if (date != null) {
      setState(() {
        _fill.date = date;
      });
    }
  }

  _loadCars() async {
    final List<Car> cars = await UserService.instance.getMyCarList();
    setState(() {
      _myCars = cars;
    });
  }

  List<DropdownMenuItem<Car>> _getCarsDropdownMenuItems() {
    if (_myCars == null) {
      return List(0);
    }

    List<DropdownMenuItem<Car>> result = List();
    _myCars.forEach((car) {
      result.add(DropdownMenuItem<Car>(
          value: car, child: Text('${car.brand} ${car.model}')));
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('New fill'),
      ),
      body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            autovalidate: true,
            key: _formKey,
            child: ListView(
              children: <Widget>[
                InputDecorator(
                  decoration: InputDecoration(
                      labelText: 'Car',
                      errorText: _showErrors == true && _car == null
                          ? 'Required'
                          : null),
                  isEmpty: _car == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Car>(
                      onChanged: (Car value) {
                        setState(() {
                          _car = value;
                          _odometerController.text =
                              value.initialOdometer.toString();
                        });
                      },
                      value: _car,
                      isDense: true,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: const Color(0xFF202020),
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Roboto'),
                      items: _getCarsDropdownMenuItems(),
                    ),
                  ),
                ),
                InputDecorator(
                    decoration:
                        InputDecoration(labelText: 'Date', errorText: null),
                    isEmpty: _fill.date == null,
                    child: InkWell(
                      child: Text(
                          '${_fill.date.month}/${_fill.date.day}/${_fill.date
                              .year}'),
                      onTap: () => _selectDate(context),
                    )),
                TextFormField(
                  controller: _odometerController,
                  validator: (value) {
                    var odometer = int.tryParse(value);
                    if (!(odometer is int)) {
                      return 'Invalid value';
                    }
                  },
                  onSaved: (String value) {
                    _fill.kilometers = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Current odometer'),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Roboto'),
                ),
                TextFormField(
                  validator: (value) {
                    var liters = double.tryParse(value);
                    if (!(liters is double) || liters == 0) {
                      return 'Invalid value';
                    }
                  },
                  initialValue: '0',
                  onSaved: (String value) {
                    _fill.liters = double.parse(value);
                  },
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  decoration: InputDecoration(labelText: 'Liters'),
                  style: TextStyle(
                      fontSize: 12.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Roboto'),
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        var price = double.tryParse(value);
                        if (!(price is double) || price == 0) {
                          return 'Invalid value';
                        }
                      },
                      initialValue: '0',
                      onSaved: (String value) {
                        _fill.price = double.parse(value);
                      },
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      decoration: InputDecoration(labelText: 'Price'),
                      style: TextStyle(
                          fontSize: 12.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Roboto'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    child: Checkbox(
                      value: _fill.fullCharge,
                      onChanged: (value) {
                        setState(() {
                          _fill.fullCharge = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    child: Text('Full charge'),
                    margin: EdgeInsets.only(top: 20.0),
                  )
                ]),
                Container(
                  width: screenSize.width,
                  child: RaisedButton(
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _submitFill(),
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

  void _submitFill() {
    print(_fill.toMap())                                ;
    if (_formKey.currentState.validate() && _fill.carId != null) {
      UserService.instance.addFillUp(_fill);
    } else {
      setState(() {
        _showErrors = true;
      });
    }
  }
}
