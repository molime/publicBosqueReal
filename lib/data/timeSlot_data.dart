import 'dart:collection';

import 'package:bosque_real/model/reservation.dart';
import 'package:bosque_real/model/timeSlot.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

final timesRef = FirebaseFirestore.instance.collection('timeSlots');
final reservationRef = FirebaseFirestore.instance.collection('reservations');

class TimeSlotData extends ChangeNotifier {
  List<TimeSlot> _times = [];
  TimeSlot _timeSlot;

  UnmodifiableListView<TimeSlot> get times {
    return UnmodifiableListView(_times);
  }

  TimeSlot get timeSlot {
    return _timeSlot;
  }

  bool isTimeSlot({TimeSlot timeSlot}) {
    if (_timeSlot == null) {
      return false;
    } else {
      return _timeSlot.uid == timeSlot.uid;
    }
  }

  void setTimeSlot({TimeSlot timeSlot, ReservationMade reservationMade}) {
    _timeSlot = timeSlot;
    notifyListeners();
  }

  void deleteTimeSlot() {
    _timeSlot = null;
    notifyListeners();
  }

  void addTime({TimeSlot timeSlot}) {
    if (_times.indexWhere((element) => element.uid == timeSlot.uid) < 0) {
      _times.add(timeSlot);
      notifyListeners();
    }
  }

  Future<void> initTimes() async {
    QuerySnapshot querySnapshot = await timesRef.orderBy('minutesTotal').get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if (_times.indexWhere((element) => element.uid == documentSnapshot.id) <
          0) {
        _times.add(
          TimeSlot.fromDocument(doc: documentSnapshot),
        );
        notifyListeners();
      }
    }
    notifyListeners();
  }
}
