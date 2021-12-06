import 'package:flutter/foundation.dart';
import 'package:bosque_real/config/auth.dart';
import 'package:bosque_real/model/user.dart';

class UserData extends ChangeNotifier {
  UserLocal _user;
  bool signedIn = false;

  bool isAuth = false;
  final DateTime timestamp = DateTime.now();

  UserLocal get user {
    return _user;
  }

  void setUser({UserLocal user}) {
    _user = user;
    signedIn = true;
    notifyListeners();
  }

  void changeName({String newName}) async {
    await _user.changeName(newName: newName);
    notifyListeners();
  }

  void makeValid() {
    _user.makeValid();
    notifyListeners();
  }

  void changePhone({String newPhone}) async {
    await _user.changePhone(newPhone: newPhone);
    notifyListeners();
  }

  Future<void> changePhoto({String newPhoto}) async {
    await _user.changePhoto(newPhotoUrl: newPhoto);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    signedIn = false;
    notifyListeners();
  }
}
