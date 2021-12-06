import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:bosque_real/model/user.dart';
import 'package:bosque_real/data/user_data.dart';

SharedPreferences prefs;

CollectionReference usersRefAuth =
    FirebaseFirestore.instance.collection('users');

final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();
}

Future<Map> signUp({
  String email,
  String password,
  String name,
  String membership,
  String phone,
}) async {
  try {
    final UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    List<String> charList = name.trim().toLowerCase().split('');
    List<String> searchList = [];

    for (int i = 0; i < charList.length; i++) {
      if (i == 0) {
        searchList.add(charList[i]);
      } else {
        String searchString = searchList[i - 1] + charList[i];
        searchList.add(searchString);
      }
    }

    await usersRefAuth.doc(user.user.uid).set({
      "id": user.user.uid,
      "photoUrl": "",
      "email": user.user.email,
      "displayName": name,
      "membership": membership != null ? membership : null,
      "phone": phone,
      "validated": false,
      "timestamp": DateTime.now(),
      'searchTerms': searchList,
    });

    DocumentSnapshot doc = await usersRefAuth.doc(user.user.uid).get();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userUid', user.user.uid);
    return {'result': 'success', 'userDoc': UserLocal.fromDocument(doc)};
  } catch (err) {
    return {'result': 'error', 'error': err.toString()};
  }
}

Future<Map> signIn({
  String email,
  String password,
}) async {
  try {
    final user =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    Map response = await getUserDatabase(
      uid: user.user.uid,
    );
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userUid', user.user.uid);
    return response;
  } catch (err) {
    return {
      'result': 'error',
      'message':
          'No se encontró un usuario registrado con la información proporcionada'
    };
  }
}

Future<Map> getUserDatabase({
  String uid,
}) async {
  final DocumentSnapshot user = await usersRefAuth.doc(uid).get();
  if (user != null) {
    final UserLocal userDoc = UserLocal.fromDocument(user);
    return {'result': 'success', 'userDoc': userDoc};
  } else {
    auth.signOut();
    return {
      'result': 'error',
      'message':
          'No se encontró un usuario registrado con la información proporcionada'
    };
  }
}

Future<void> logout() async {
  await auth.signOut();
  prefs.setBool('isLoggedIn', false);
  prefs.setString('userUid', '');
}
