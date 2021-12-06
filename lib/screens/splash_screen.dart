import 'dart:async';

import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/user.dart';
import 'package:bosque_real/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bosque_real/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bosque_real/screens/auth/login.dart';
import 'package:bosque_real/config/auth.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final String route;

  SplashScreen({this.route});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        checkRoute();
      },
    );
  }

  void checkRoute() async {
    //print({'prefs': prefs.toString()});
    bool isLoggedIn = prefs.getBool('isLoggedIn');
    //print({'isLoggedIn': isLoggedIn});
    if (isLoggedIn != null) {
      if (isLoggedIn) {
        String userUid = prefs.getString('userUid');
        DocumentSnapshot userDatabase = await usersRefAuth.doc(userUid).get();
        if (userDatabase.exists) {
          UserLocal userLocal = UserLocal.fromDocument(userDatabase);
          prefs.setBool('isLoggedIn', true);
          prefs.setString('userUid', userDatabase.id);
          Provider.of<UserData>(context, listen: false)
              .setUser(user: userLocal);
          Timer(
              Duration(seconds: 3),
              () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  ));
        } else {
          prefs.setBool('isLoggedIn', false);
          prefs.setString('userUid', '');
          auth.signOut();
          Provider.of<UserData>(context, listen: false).clearUser();
          Timer(
              Duration(seconds: 3),
              () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  ));
        }
      } else {
        //print('before set loggedIn');
        prefs.setBool('isLoggedIn', false);
        //print('before set userUid');
        prefs.setString('userUid', '');
        //print('before clearing user');
        Provider.of<UserData>(context, listen: false).clearUser();
        //print('after clearing user');
        Timer(
            Duration(seconds: 3),
            () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                ));
      }
    } else {
      prefs.setBool('isLoggedIn', false);
      prefs.setString('userUid', '');
      Provider.of<UserData>(context, listen: false).clearUser();
      Timer(
          Duration(seconds: 3),
          () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        body: Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/bosquereal_logo.png',
                  width: 200.0,
                  fit: BoxFit.fitWidth,
                ),
                heightSpace,
                heightSpace,
                heightSpace,
                SpinKitPulse(
                  color: primaryColor,
                  size: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
