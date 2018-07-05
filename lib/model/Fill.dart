class Fill {
  String id;
  String carId;
  DateTime date;
  int kilometers;
  double liters;
  double price;
  bool fullCharge;

  Fill(){
    date = DateTime.now();
    fullCharge = true;
  }

  Fill.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    carId = map['carId'];
    date = map['date'];
    kilometers = map['kilometers'];
    liters = map['liters'];
    price = map['price'];
    fullCharge = map['fullCharge'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'car_id': carId,
      'date': date,
      'kilometers': kilometers,
      'liters': liters,
      'price': price,
      'fullCharge': fullCharge,
    };
  }
}
