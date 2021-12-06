import 'dart:collection';

import 'package:bosque_real/data/timeSlot_data.dart';
import 'package:bosque_real/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:bosque_real/model/reservation.dart';
import 'package:bosque_real/utilities/functions.dart';
import 'package:provider/provider.dart';

class ReservationData extends ChangeNotifier {
  DateTime _dateTimeSelected;
  DateTime _currentDate;
  int _minutesTotal;
  bool _isLoading = false;
  List<DateTime> _dateTimesFuture = [];
  ReservationMade _reservationMade;
  Stream<ReservationMade> _reservationStream;
  List<UserLocal> _teamPlayers = [];
  List<String> _guests = [];
  int _quedan = 1;

  ReservationMade get reservationMade {
    return _reservationMade;
  }

  DateTime get dateTimeSelected {
    return _dateTimeSelected;
  }

  DateTime get currentDate {
    return _currentDate;
  }

  UnmodifiableListView<DateTime> get dateTimesFuture {
    return UnmodifiableListView(_dateTimesFuture);
  }

  int get minutesTotal {
    return _minutesTotal;
  }

  Stream<ReservationMade> get reservationStream {
    return _reservationStream;
  }

  UnmodifiableListView<UserLocal> get teamPlayers {
    return UnmodifiableListView(_teamPlayers);
  }

  UnmodifiableListView<String> get guests {
    return UnmodifiableListView(_guests);
  }

  int get quedan {
    return _quedan;
  }

  int get guestsPlusMembersAdded {
    return _guests.length + _teamPlayers.length;
  }

  bool numPeopleChecks() {
    if (_reservationMade != null) {
      return _reservationMade.numJugadores - 1 ==
          _teamPlayers.length + _guests.length;
    } else {
      return false;
    }
  }

  bool allowReservationCreation() {
    if (_reservationMade != null) {
      print({'guestsPlusMembersAdded': guestsPlusMembersAdded});
      return guestsPlusMembersAdded + 1 == _reservationMade.numJugadores &&
          guestsAllowed();
    } else {
      return false;
    }
  }

  bool guestsAllowed() {
    if (_reservationMade != null) {
      return _reservationMade.guests.length + guests.length <= 2;
    } else {
      return false;
    }
  }

  bool allowAddGuests() {
    if (_reservationMade != null) {
      if (_reservationMade.guests.length + guests.length > 2) {
        return false;
      } else if (numPeopleChecks()) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  void addNumPeople({int numPeople}) {
    //print({'addNumPeople': numPeople});
    _reservationMade.addPeople(numPeople: numPeople);
    notifyListeners();
  }

  void addPlayer({UserLocal userLocal}) {
    if (_teamPlayers.indexWhere((element) => element.id == userLocal.id) < 0) {
      _teamPlayers.add(userLocal);
      notifyListeners();
    }
  }

  void addGuest({String guest}) {
    print('adding guest called');
    if (_guests.indexWhere((element) => element == guest) < 0 &&
        allowAddGuests()) {
      print({'guest': guest, 'msg': 'Adding guests is allowed'});
      _guests.add(guest);
      notifyListeners();
    }
  }

  void deletePlayer({UserLocal userLocal}) {
    if (_teamPlayers.indexWhere((element) => element.id == userLocal.id) >= 0) {
      UserLocal userRemove = _teamPlayers.firstWhere(
          (element) => element.id == userLocal.id,
          orElse: () => null);

      if (userRemove != null) {
        _teamPlayers.remove(userRemove);
      }
      notifyListeners();
    }
  }

  void deleteGuest({String guest}) {
    if (_guests.indexWhere((element) => element == guest) >= 0) {
      String guestRemove =
          _guests.firstWhere((element) => element == guest, orElse: () => null);
      if (guestRemove != null) {
        _guests.remove(guestRemove);
      }
    }
    notifyListeners();
  }

  void setQuedan({int newQuedan}) {
    print({'newQuedan': newQuedan});
    if (newQuedan != null) {
      _quedan = newQuedan;
    }
    print({'_quedan': _quedan});
    notifyListeners();
  }

  void clearPlayers() {
    _teamPlayers = [];
    notifyListeners();
  }

  void clearGuests() {
    _guests = [];
    notifyListeners();
  }

  bool showLoading(BuildContext context) {
    if (_isLoading) {
      return true;
    } else if (Provider.of<TimeSlotData>(context, listen: false).times.length >
            0 &&
        _currentDate != null &&
        _minutesTotal != null &&
        _dateTimesFuture.length > 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> futureDates() async {
    _isLoading = true;
    DateTime dateTime = await currentTime();
    String hourString = DateFormat.Hm().format(dateTime);

    int hour = int.parse(
      hourString.substring(
        0,
        hourString.indexOf(":"),
      ),
    );
    int minutes = int.parse(
      hourString.substring(
        hourString.indexOf(":") + 1,
        hourString.length,
      ),
    );
    int minutesTotal = (hour * 60) + minutes;

    List<DateTime> dateTimesFuture = await setDaysFuture();

    //print({'currentDate': dateTime});

    _currentDate = dateTime;
    _minutesTotal = minutesTotal;
    _dateTimesFuture = dateTimesFuture;

    print({
      '_currentDate': _currentDate,
      '_minutesTotal': _minutesTotal,
      '_dateTimesFuture': _dateTimesFuture
    });

    _isLoading = false;

    notifyListeners();
  }

  Future<List<DateTime>> setDaysFuture() async {
    List<DateTime> daysAvailableFuture = [];
    DateTime dateTime = await currentTime();
    DateTime tomorrow = dateTime.add(
      Duration(
        days: 1,
      ),
    );
    DateTime todayAdd = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    DateTime tomorrowAdd = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
    );
    if (daysAvailableFuture.length < 1) {
      daysAvailableFuture.add(
        todayAdd,
      );
      daysAvailableFuture.add(
        tomorrowAdd,
      );
    } else if (daysAvailableFuture
                .indexWhere((dateList) => dateList.compareTo(dateTime) == 0) <
            0 ||
        daysAvailableFuture
                .indexWhere((dateList) => dateList.compareTo(dateTime) == 0) <
            0) {
      daysAvailableFuture = [
        todayAdd,
        tomorrowAdd,
      ];
    }
    if (_dateTimeSelected == null) {
      setSelectedDate(dateTime: todayAdd);
    }

    return daysAvailableFuture;
  }

  bool isSelectedDate({DateTime dateTime}) {
    /*print({
      'dateTime null': dateTime == null,
      '_dateTime null': _dateTimeSelected == null,
    });*/
    if (_dateTimeSelected != null) {
      return _dateTimeSelected.year == dateTime.year &&
          _dateTimeSelected.month == dateTime.month &&
          _dateTimeSelected.day == dateTime.day;
    } else {
      return false;
    }
  }

  void setReservation({
    ReservationMade reservationMade,
    String timeSlot,
  }) {
    if (reservationMade != null) {
      _reservationMade = reservationMade;
      notifyListeners();
    } else {
      _reservationMade = ReservationMade.empty(
        dateTime: _dateTimeSelected,
        timeSlot: timeSlot,
      );
      notifyListeners();
    }
  }

  void deleteReservation() {
    _reservationMade = null;
    notifyListeners();
  }

  void setSelectedDate({DateTime dateTime}) {
    _dateTimeSelected = dateTime;
    notifyListeners();
  }

  void deleteSelectedDate() {
    _dateTimeSelected = null;
    notifyListeners();
  }
}
