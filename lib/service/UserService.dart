import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Car.dart';

class UserService {

  static final UserService instance = UserService();


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> getFirebaseUser() async {
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

  Future<List<Car>> getMyCarList(FirebaseUser user) async {
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
      return List(0);
    }

    final carsArray = cars.documents;

    List<Car> carList = List();
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