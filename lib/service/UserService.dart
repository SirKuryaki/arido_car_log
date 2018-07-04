import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Car.dart';

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
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  Future<List<Car>> getMyCarList() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    String userId = currentUser.uid;
    DocumentSnapshot doc =
        await _firestore.collection('users').document(userId).get();
    if (doc == null || !doc.exists) {
      final DocumentReference ref =
          _firestore.collection('users').document(userId);
      await ref.setData({'id': userId});
      doc = await ref.get();
    }

    final cars = await _firestore
        .collection('cars')
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
    _firestore
        .collection('cars')
        .document()
        .setData(car.toMap(currentUser.uid));
  }
}
