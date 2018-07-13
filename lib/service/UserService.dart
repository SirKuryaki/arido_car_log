import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';

import '../model/Car.dart';
import '../model/Fill.dart';

const String USERS = 'users';
const String CARS = 'cars';
const String FILLS = 'fills';

class UserService {
  static final UserService instance =
      UserService(Firestore.instance, FirebaseAuth.instance, GoogleSignIn());

  final Firestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  UserService(this._firestore, this._auth, this._googleSignIn);

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

    final FirebaseUser currentUser = await _auth.currentUser();

    DocumentSnapshot doc =
        await _firestore.collection(USERS).document(currentUser.uid).get();
    if (doc == null || !doc.exists) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final DocumentReference ref =
          _firestore.collection(USERS).document(currentUser.uid);
      await ref.setData({
        'id': currentUser.uid,
        'app_version': packageInfo.version,
        'platform': Platform.operatingSystem
      });
    }

    return user;
  }

  Future<bool> isLogged() async {
    FirebaseUser user = await getFirebaseUser();
    return user != null;
  }

  Future<List<Car>> getMyCarList() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    String userId = currentUser.uid;

    final cars = await _firestore
        .collection(CARS)
        .where("user_id", isEqualTo: userId)
        .getDocuments();
    if (cars.documents.isEmpty) {
      return List(0);
    }

    final carsArray = cars.documents;

    final List<Car> carList = List();
    for (final document in carsArray) {
      carList.add(Car.fromMap(document.data));
    }

    return carList;
  }

  Future<void> saveCar(Car car) async {
    final FirebaseUser currentUser = await _auth.currentUser();
    DocumentReference ref = _firestore.collection(CARS).document();
    car.userId = currentUser.uid;
    car.id = ref.documentID;
    ref.setData(car.toMap());
  }

  Future<void> addFillUp(Fill fill) async {
    DocumentReference ref = _firestore.collection(FILLS).document();
    fill.id = ref.documentID;
    ref.setData(fill.toMap());
  }
}
