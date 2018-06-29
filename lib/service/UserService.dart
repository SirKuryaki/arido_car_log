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
        await Firestore.instance.collection('users').document(user.uid).get();
    if (doc == null || !doc.exists) {
      final DocumentReference ref =
          Firestore.instance.collection('users').document(user.uid);
      await ref.setData({'id': user.uid});
      doc = await ref.get();
    }

    final cars = await Firestore.instance.collection('cars').where("user_id", isEqualTo:user.uid).getDocuments();
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
    Firestore.instance
        .collection('cars')
        .document()
        .setData(car.toMap(currentUser.uid));
  }
}
