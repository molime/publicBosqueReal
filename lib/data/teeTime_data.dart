import 'dart:collection';

import 'package:bosque_real/model/teeTime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TeeTimeData extends ChangeNotifier {
  List<TeeTime> _teeTimes = [];
  List<TeeTime> _teeTimesDateSelected = [];
  TeeTime _teeTimeSelected;

  UnmodifiableListView<TeeTime> get teeTimes {
    return UnmodifiableListView(_teeTimes);
  }

  UnmodifiableListView<TeeTime> get teeTimesSelected {
    return UnmodifiableListView(_teeTimesDateSelected);
  }

  TeeTime get teeTimeSelected {
    return _teeTimeSelected;
  }

  bool isTeeTime({TeeTime teeTime}) {
    if (teeTime == null) {
      return false;
    } else {
      return teeTime.uid == _teeTimeSelected.uid;
    }
  }

  void addTeeTime({TeeTime teeTime}) {
    if (_teeTimes.indexWhere((element) => element.uid == teeTime.uid) < 0) {
      _teeTimes.add(teeTime);
      notifyListeners();
    }
  }

  void setTeeTime({TeeTime teeTime}) {
    _teeTimeSelected = teeTime;
    notifyListeners();
  }

  void setTeeTimesDateSelected({List<TeeTime> teeTimesList}) {
    if (teeTimesList != null) {
      _teeTimesDateSelected = teeTimesList;
    }
    notifyListeners();
  }

  void deleteListTeeTimesDate() {
    _teeTimesDateSelected = [];
    notifyListeners();
  }

  void deleteTeeTime() {
    _teeTimeSelected = null;
    notifyListeners();
  }

  Future<void> initTeeTimes({String userId}) async {
    //print('starting tee times');

    QuerySnapshot querySnapshot = await teeTimeRef
        .where('user', isEqualTo: userId)
        .orderBy('timeMade', descending: true)
        .get();

    for (DocumentSnapshot doc in querySnapshot.docs) {
      if (_teeTimes.indexWhere((element) => element.uid == doc.id) < 0) {
        _teeTimes.add(
          TeeTime.fromDocument(doc: doc),
        );
        notifyListeners();
      }
    }

    notifyListeners();
  }
}
