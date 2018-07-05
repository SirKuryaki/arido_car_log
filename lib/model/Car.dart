class Car {
  String id;
  String userId;
  String brand;
  String model;
  String version;
  int initialOdometer;
  String fuelType;
  String measureUnit;

  Car();

  Car.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    brand = map['brand'];
    model = map['model'];
    version = map['version'];
    initialOdometer = map['initialOdometer'];
    fuelType = map['fuelType'];
    measureUnit = map['measureUnit'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'version': version,
      'initialOdometer': initialOdometer,
      'fuelType': fuelType,
      'measureUnit': measureUnit
    };
  }
}
