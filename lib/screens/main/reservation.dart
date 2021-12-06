import 'dart:async';

import 'package:bosque_real/config/auth.dart';
import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/data/timeSlot_data.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/timeSlot.dart';
import 'package:bosque_real/model/user.dart';
import 'package:bosque_real/screens/main/reservation/main_reservation.dart';
import 'package:bosque_real/screens/main/reservation/search_players.dart';
import 'package:bosque_real/utilities/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:provider/provider.dart';

class Reservation extends StatefulWidget {
  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  int people = 1;
  int seconds;
  bool searching = false;
  List<UserLocal> tempSearchStore = [];
  List<UserLocal> usersAdded = [];
  var queryResult = [];
  String queryString;
  List<DateTime> daysAvailable = [];
  DateTime dateSelected;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  bool searchingPlayers = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimes();
    futureDates();
    //setDays();
  }

  Future<void> futureDates() async {
    await Provider.of<ReservationData>(context, listen: false).futureDates();
  }

  Future<void> startTimes() async {
    await Provider.of<TimeSlotData>(context, listen: false).initTimes();
  }

  void setDays() async {
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
    if (daysAvailable.length < 1) {
      daysAvailable.add(
        todayAdd,
      );
      daysAvailable.add(
        tomorrowAdd,
      );
    } else if (daysAvailable
                .indexWhere((dateList) => dateList.compareTo(dateTime) == 0) <
            0 ||
        daysAvailable
                .indexWhere((dateList) => dateList.compareTo(dateTime) == 0) <
            0) {
      daysAvailable = [
        todayAdd,
        tomorrowAdd,
      ];
    }
    if (Provider.of<ReservationData>(context, listen: false).dateTimeSelected ==
        null) {
      Provider.of<ReservationData>(context, listen: false)
          .setSelectedDate(dateTime: todayAdd);
    }
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
    if (Provider.of<ReservationData>(context, listen: false).dateTimeSelected ==
        null) {
      Provider.of<ReservationData>(context, listen: false)
          .setSelectedDate(dateTime: todayAdd);
    }

    return daysAvailableFuture;
  }

  void initiateSearch({String searchValue}) async {
    String newSearch = searchValue.trim().toLowerCase();

    if (newSearch.length == 0) {
      setState(() {
        queryResult = [];
        tempSearchStore = [];
      });
    } else {
      setState(() {
        tempSearchStore = [];
      });

      QuerySnapshot results = await usersRefAuth
          .where('searchTerms', arrayContains: newSearch)
          .where("id",
              isNotEqualTo:
                  Provider.of<UserData>(context, listen: false).user.id)
          .get();

      for (DocumentSnapshot documentSnapshot in results.docs) {
        setState(() {
          if (tempSearchStore
                  .indexWhere((element) => element.id == documentSnapshot.id) <
              0) {
            tempSearchStore.add(
              UserLocal.fromDocument(documentSnapshot),
            );
          }
        });
      }
    }
  }

  Future<Map> getTime() async {
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

    List<DateTime> dateTimesFuture;

    if (mounted) {
      dateTimesFuture = await setDaysFuture();
    }

    Map mapReturn = {
      'dates': dateTime,
      'times': Provider.of<TimeSlotData>(context, listen: false).times,
      'minutesTotal': minutesTotal,
      'datesList': dateTimesFuture,
    };

    print('called getTime');

    return mapReturn;
  }

  /*Stream<DateTime> getTime() async* {
    while (true) {
      await Future.delayed(
        Duration(
          seconds: 10,
        ),
      );
      DateTime dateTime = await currentTime();
      yield dateTime;
    }
  }*/

  void _showDialog({BuildContext context}) {
    Picker(
        adapter: NumberPickerAdapter(
          data: [
            NumberPickerColumn(
              initValue: people,
              begin: 1,
              end: Provider.of<ReservationData>(context, listen: false).quedan,
              jump: 1,
            ),
          ],
        ),
        hideHeader: true,
        title: Text("Haz una selección"),
        selectedTextStyle: TextStyle(
          color: Color(0xFFe2b13c),
        ),
        confirmTextStyle: TextStyle(
          color: Color(0xFFe2b13c),
        ),
        cancelTextStyle: TextStyle(
          color: Color(0xFFe2b13c),
        ),
        onConfirm: (Picker picker, List value) {
          print('confirming value');
          int valueSet = picker.getSelectedValues()[0];
          if (value != null) {
            setState(() {
              people = valueSet;
            });
            print({'valueSet': valueSet});
            Provider.of<ReservationData>(context, listen: false)
                .addNumPeople(numPeople: valueSet);
            print({
              'numPeople': Provider.of<ReservationData>(context, listen: false)
                  .reservationMade
                  .numJugadores
            });
          }
        }).showDialog(context);
    /*showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return NumberPicker(
                minValue: 1,
                maxValue:
                    Provider.of<ReservationData>(context, listen: false).quedan,
                value: people,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      people = value;
                    });
                    Provider.of<ReservationData>(context, listen: false)
                        .addNumPeople(numPeople: value);
                  }
                }) */ /*NumberPickerDialog.integer(
          initialIntegerValue: people,
          minValue: 1,
          maxValue: Provider.of<ReservationData>(context, listen: false).quedan,
        )*/ /*
            ;
      },
    ) */ /*.then((value) {
      if (value != null) {
        setState(() {
          people = value;
        });
        Provider.of<ReservationData>(context, listen: false)
            .addNumPeople(numPeople: value);
      }
    })*/
  }

  void _showSelectPeople(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Faltan jugadores',
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    'Para buscar jugadores el número de jugadores en la reserva debe de ser de más de uno',
                    style: GoogleFonts.barlow(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                color: Colors.red,
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showDialogIncomplete(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Falta información',
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    'Falta que selecciones la fecha, la hora, o ambos',
                    style: GoogleFonts.barlow(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                color: Colors.red,
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setDays();
  }

  @override
  Widget build(BuildContext context) {
    return !searching
        ? mainReservationScreen(
            showSpinner: showSpinner,
            changeSpinner: (value) {
              setState(() {
                showSpinner = value;
              });
            },
            scaffoldKey: _scaffoldKey,
            refreshController: refreshController,
            context: context,
            warningSelect: () {
              _showDialogIncomplete(context);
            },
            getTime: getTime(),
            selectPlayers: () {
              _showDialog(
                context: context,
              );
            },
            onRefreshIndicator: () async {
              setState(() {
                getTime();
              });
            },
            doPressed: () {
              print({
                'numJugadores':
                    Provider.of<ReservationData>(context, listen: false)
                        .reservationMade
                        .numJugadores,
                'quedan - 1':
                    Provider.of<ReservationData>(context, listen: false)
                            .quedan -
                        1
              });
              if (Provider.of<ReservationData>(context, listen: false)
                          .reservationMade
                          .numJugadores >
                      1 &&
                  Provider.of<ReservationData>(context, listen: false)
                          .guestsPlusMembersAdded <
                      Provider.of<ReservationData>(context, listen: false)
                          .quedan &&
                  Provider.of<ReservationData>(context, listen: false)
                          .guestsPlusMembersAdded <
                      Provider.of<ReservationData>(context, listen: false)
                          .reservationMade
                          .numJugadores) {
                setState(() {
                  searching = true;
                });
              } else {
                _showSelectPeople(context);
              }
            },
          )
        : SearchScreen(
            onSearchDone: () {
              setState(() {
                searching = false;
              });
            },
            onBackPressed: () {
              setState(() {
                searching = false;
              });
            },
          );
    /*searchScreen(
            numPlayers: people,
            context: context,
            tempSearchStore: tempSearchStore,
            searchFunction: (value) {
              setState(() {
                queryString = value;
              });
              initiateSearch(searchValue: queryString);
            },
            onBackPressed: () {
              setState(() {
                searching = false;
              });
            },
            onSearchDone: () {
              setState(() {
                searching = false;
              });
            });*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mounted;
  }
}
