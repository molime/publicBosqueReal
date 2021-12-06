import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/data/teeTime_data.dart';
import 'package:bosque_real/data/timeSlot_data.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/teeTime.dart';
import 'package:bosque_real/model/timeSlot.dart';
import 'package:bosque_real/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:bosque_real/model/reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:qr/qr.dart';
import 'dart:math';
import 'package:ntp/ntp.dart';

final firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref();

Future<DateTime> currentTime() async {
  //String endpoint = 'http://worldtimeapi.org/api/timezone/America/Mexico_City';
  //String endpoint = 'https://timezone.abstractapi.com/v1/current_time?api_key=50d8587a94894a12b92bf1f8a160fd69&location=Mexico City, Mexico';

  DateTime nowDate = await NTP.now();

  return nowDate;

  /*String endpoint =
      'https://timezoneapi.io/api/timezone/?America/Chicago&token=akRTYdDvEzpSBIFxZmrh';

  http.Response response = await http.get(endpoint);

  if (response.statusCode == 200) {
    print('success getting the times');
    Map data = jsonDecode(response.body);

    String datetime = data['data']["datetime"]['date_time'].toString();
    print({
      'dateTime': data['data']["datetime"]['date_time'].toString(),
      'am/pm': data['data']["datetime"]["hour_am_pm"].toString(),
    });
    */ /*String offset = data["utc_offset"].toString().substring(
      0,
      3,
    );*/ /*

    //DateFormat('dd/MM/yyyy hh:mm:ss', datetime);

    //DateTime now = DateTime.parse(datetime);
    DateTime now = DateFormat('MM/dd/yyyy hh:mm:ss').parse(datetime);
    if (now.hour == 0) {
      if (data['data']["datetime"]["hour_am_pm"].toString() != "am") {
        now = DateTime(
          now.year,
          now.month,
          now.day,
          12,
          now.minute,
        );
      }
    }
    */ /*now = now.add(
      Duration(
        hours: int.parse(
          offset,
        ),
      ),
    );*/ /*

    return now;
  } else {
    print('error');
    print(
      response.body.toString(),
    );
    return null;
  }*/
}

String weekday(int dayInt) {
  switch (dayInt) {
    case 1:
      {
        return 'LU';
      }
      break;
    case 2:
      {
        return 'MA';
      }
      break;
    case 3:
      {
        return 'MI';
      }
      break;
    case 4:
      {
        return 'JU';
      }
      break;
    case 5:
      {
        return 'VI';
      }
      break;
    case 6:
      {
        return 'SA';
      }
      break;
    case 7:
      {
        return 'DO';
      }
      break;
    default:
      {
        return 'NA';
      }
      break;
  }
}

Stream<List<ReservationMade>> streamReservation({DateTime dateTime}) {
  var reservationRef =
      FirebaseFirestore.instance.collection('reservations').where('dateTime',
          isEqualTo: DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
          ));

  return reservationRef.snapshots().map((list) {
    return list.docs.map((doc) => ReservationMade.fromQuery(doc: doc)).toList();
  });
}

String getHourString({int hour, int minute}) {
  String hourString = hour.toString();
  String minuteString = minute.toString();

  if (hourString.length == 1) {
    hourString = "0" + hourString;
  }

  if (minuteString.length == 1) {
    minuteString = minuteString + "0";
  }

  return hourString + ":" + minuteString;
}

bool datesEqual({DateTime dateSelected, DateTime dateCompare}) {
  if (dateSelected == null || dateCompare == null) {
    return false;
  } else {
    return dateSelected.year == dateCompare.year &&
        dateSelected.month == dateCompare.month &&
        dateSelected.day == dateCompare.day;
  }
}

bool timeSlotEqual({String timeSelectedUid, String timeCompare}) {
  if (timeSelectedUid == null || timeCompare == null) {
    return false;
  } else {
    return timeSelectedUid == timeCompare;
  }
}

int lugaresQuedan({ReservationMade reservationMade}) {
  if (reservationMade == null) {
    return 5;
  } else {
    return 5 - reservationMade.numJugadores;
  }
}

Stream<ReservationMade> reservationToStream({
  String reservationUid,
  DateTime dateTime,
  String timeSlotUid,
}) {
  var reservationRef = FirebaseFirestore.instance.collection('reservations');

  if (reservationUid != null) {
    return reservationRef.doc(reservationUid).snapshots().map(
          (doc) => ReservationMade.fromDocument(
            doc: doc,
          ),
        );
  } else {
    return reservationRef
        .where('timeSlot', isEqualTo: timeSlotUid)
        .where('dateTime', isEqualTo: dateTime)
        .snapshots()
        .map(
          (list) => ReservationMade.fromDocument(
            doc: list.docs[0],
          ),
        );
  }
}

bool useStream({TimeSlot timeSlot, DateTime dateTime}) {
  if (timeSlot != null && dateTime != null) {
    return true;
  } else {
    return false;
  }
}

ReservationMade findReservation({
  List<ReservationMade> reservations,
  DateTime dateSelected,
  String timeCompare,
}) {
  //print({'timeCompare': timeCompare});
  if (reservations.length < 1) {
    //print('resLength < 1');
    return null;
  } else {
    //print('resLength >= 1');
    List<ReservationMade> reservationsDate = reservations
        .where(
          (element) => datesEqual(
            dateSelected: dateSelected,
            dateCompare: element.dateTime,
          ),
        )
        .toList();
    if (reservationsDate.length < 1) {
      //print('resDate.length < 1');
      return null;
    }

    //print('resDate.length >= 1');
    ReservationMade reservationTime = reservationsDate.firstWhere(
        (element) => timeSlotEqual(
              timeCompare: timeCompare,
              timeSelectedUid: element.timeSlot,
            ),
        orElse: () => null);

    //print({'resTime': reservationTime != null});
    if (reservationTime != null) {
      //print('resTime != null');
      return reservationTime;
    } else {
      //print('resTime == null');
      return null;
    }
  }
}

List<TimeSlot> timeSlots({
  List<TimeSlot> times,
  DateTime dateSelected,
  DateTime dateNow,
}) {
  //int minutes = 0;
  int minutes = (dateNow.hour * 60) + dateNow.minute;
  /*print({
    'minutes timeSlots': minutes,
    'hour': dateNow.hour,
    'minutes': dateNow.minute,
  });*/

  if (datesEqual(dateSelected: dateSelected, dateCompare: dateNow)) {
    return times.where((element) => element.minutesTotal >= minutes).toList();
  } else if (minutes < 390) {
    return [];
  } else {
    return times;
  }
}

Future<bool> createReservation(
    {BuildContext context,
    CollectionReference reservationRef,
    List<String> guests,
    List<UserLocal> players,
    UserLocal host}) async {
  String resUid = host.id;
  DateTime dateAdd =
      Provider.of<ReservationData>(context, listen: false).currentDate;
  String dateUid = '${dateAdd.day}${dateAdd.month}${dateAdd.year}';
  int numberUid =
      Provider.of<TeeTimeData>(context, listen: false).teeTimes.length + 1;
  Random random = new Random();
  int randomNumber = random.nextInt(1001);
  resUid = '$resUid$dateUid$numberUid$randomNumber';

  if (Provider.of<ReservationData>(context, listen: false)
          .reservationMade
          .uid !=
      null) {
    DocumentSnapshot doc = await reservationRef
        .doc(Provider.of<ReservationData>(context, listen: false)
            .reservationMade
            .uid)
        .get();
    ReservationMade reservationMade = ReservationMade.fromDocument(doc: doc);

    print({'doc.jugadores': (doc.data() as Map)['jugadores']});

    if (reservationMade.numJugadores +
                Provider.of<ReservationData>(context, listen: false)
                    .reservationMade
                    .numJugadores <=
            5 &&
        allowAddGuests(
            reservationDB: reservationMade,
            reservationLocal:
                Provider.of<ReservationData>(context, listen: false)
                    .reservationMade)) {
      reservationRef
          .doc(Provider.of<ReservationData>(context, listen: false)
              .reservationMade
              .uid)
          .update({
        'numJugadores': reservationMade.numJugadores +
            Provider.of<ReservationData>(context, listen: false)
                .reservationMade
                .numJugadores,
        'jugadores': changeJugadores(
          context: context,
          listToChange: (doc.data() as Map)['jugadores'],
          listPlayers: players,
        ),
        'guests': changeGuests(
          context: context,
          listGuests: (doc.data() as Map)['guests'],
          guestsAdded: guests,
        ),
      });
      /*var qr = await QrPainter(
        data: resUid,
        version: QrVersions.auto,
        gapless: false,
      ).toImage(300);*/
      File qrSend = await toQrImageData(resUid);
      String qrUrl =
          await uploadQr(imageFile: qrSend, userUid: host.id, date: dateUid);
      await teeTimeRef.doc(resUid).set({
        'reservation': Provider.of<ReservationData>(context, listen: false)
            .reservationMade
            .uid,
        'user': host.id,
        'timeMade':
            Provider.of<ReservationData>(context, listen: false).currentDate,
        'guests': playersTeeTime(context: context),
        'qrUrl': qrUrl,
        'teeTimeDate': Provider.of<ReservationData>(context, listen: false)
            .dateTimeSelected,
        'outsideGuests': guests,
      });
      /*DocumentReference teeTimeDocRef = await teeTimeRef.add({
        'reservation': Provider.of<ReservationData>(context, listen: false)
            .reservationMade
            .uid,
        'user': Provider.of<UserData>(context, listen: false).user.id,
        'timeMade':
            Provider.of<ReservationData>(context, listen: false).currentDate,
        'guests': playersTeeTime(context: context),
      });*/
      TeeTime teeTimeOne =
          TeeTime.fromDocument(doc: await teeTimeRef.doc(resUid).get());
      Provider.of<TeeTimeData>(context, listen: false)
          .addTeeTime(teeTime: teeTimeOne);
      return true;
    } else {
      return false;
    }
  } else {
    QuerySnapshot queryElse = await reservationRef
        .where(
          'timeSlot',
          isEqualTo:
              Provider.of<TimeSlotData>(context, listen: false).timeSlot.uid,
        )
        .where(
          'dateTime',
          isEqualTo: Provider.of<ReservationData>(context, listen: false)
              .dateTimeSelected,
        )
        .get();

    if (queryElse.docs.isNotEmpty) {
      DocumentSnapshot docElse = queryElse.docs[0];
      print({'docElse.jugadores': (docElse.data() as Map)['jugadores']});
      ReservationMade reservationMadeElse =
          ReservationMade.fromDocument(doc: docElse);

      if (reservationMadeElse.numJugadores +
                  Provider.of<ReservationData>(context, listen: false)
                      .reservationMade
                      .numJugadores <=
              5 &&
          allowAddGuests(
            reservationDB: reservationMadeElse,
            reservationLocal:
                Provider.of<ReservationData>(context, listen: false)
                    .reservationMade,
          )) {
        reservationRef.doc(reservationMadeElse.uid).update({
          'numJugadores': reservationMadeElse.numJugadores +
              Provider.of<ReservationData>(context, listen: false)
                  .reservationMade
                  .numJugadores,
          'jugadores': changeJugadores(
            context: context,
            listToChange: (docElse.data() as Map)['jugadores'],
            listPlayers: players,
          ),
          'guests': changeGuests(
            context: context,
            listGuests: (docElse.data() as Map)['guests'],
            guestsAdded: guests,
          ),
        });
        /*var qr = await QrPainter(
          data: resUid,
          version: QrVersions.auto,
          gapless: false,
        ).toImage(300);*/
        File qrUpload = await toQrImageData(resUid);
        print('qrUpload');
        String qrUrl = await uploadQr(
            imageFile: qrUpload, userUid: host.id, date: dateUid);
        await teeTimeRef.doc(resUid).set({
          'reservation': reservationMadeElse.uid,
          'user': host.id,
          'timeMade':
              Provider.of<ReservationData>(context, listen: false).currentDate,
          'guests': playersTeeTime(context: context),
          'qrUrl': qrUrl,
          'teeTimeDate': Provider.of<ReservationData>(context, listen: false)
              .dateTimeSelected,
          'outsideGuests': guests,
        });
        /*DocumentReference teeTimeDocTwo = await teeTimeRef.add({
          'reservation': reservationMadeElse.uid,
          'user': Provider.of<UserData>(context, listen: false).user.id,
          'timeMade':
              Provider.of<ReservationData>(context, listen: false).currentDate,
          'guests': playersTeeTime(context: context),
        });*/
        TeeTime teeTimeTwo =
            TeeTime.fromDocument(doc: await teeTimeRef.doc(resUid).get());
        Provider.of<TeeTimeData>(context, listen: false)
            .addTeeTime(teeTime: teeTimeTwo);
        return true;
      } else {
        return false;
      }
    } else {
      DocumentReference reservationDocRef = await reservationRef.add({
        'dateTime': Provider.of<ReservationData>(context, listen: false)
            .dateTimeSelected,
        'timeSlot':
            Provider.of<TimeSlotData>(context, listen: false).timeSlot.uid,
        'numJugadores': Provider.of<ReservationData>(context, listen: false)
            .reservationMade
            .numJugadores,
        'jugadores': [
          {
            'nombre': host.displayName,
            'uid': host.id,
            'numReserved': Provider.of<ReservationData>(context, listen: false)
                .reservationMade
                .numJugadores,
          },
        ],
        'guests': guests,
      });
      /*var qr = await QrPainter(
        data: resUid,
        version: QrVersions.auto,
        gapless: false,
      ).toImage(300);*/
      File qrSendLast = await toQrImageData(resUid);
      String qrUrl = await uploadQr(
          imageFile: qrSendLast,
          userUid: Provider.of<UserData>(context, listen: false).user.id,
          date: dateUid);
      await teeTimeRef.doc(resUid).set({
        'reservation': reservationDocRef.id,
        'user': host.id,
        'timeMade':
            Provider.of<ReservationData>(context, listen: false).currentDate,
        'guests': playersTeeTime(context: context),
        'qrUrl': qrUrl,
        'teeTimeDate': Provider.of<ReservationData>(context, listen: false)
            .dateTimeSelected,
        'outsideGuests': guests,
      });
      /*DocumentReference teeTimeDocThree = await teeTimeRef.add({
        'reservation': reservationDocRef.id,
        'user': Provider.of<UserData>(context, listen: false).user.id,
        'timeMade':
            Provider.of<ReservationData>(context, listen: false).currentDate,
        'guests': playersTeeTime(context: context),
      });*/
      TeeTime teeTimeThree =
          TeeTime.fromDocument(doc: await teeTimeRef.doc(resUid).get());
      Provider.of<TeeTimeData>(context, listen: false)
          .addTeeTime(teeTime: teeTimeThree);
      return true;
    }
  }
}

List<Map> changeJugadores(
    {BuildContext context, List listToChange, List<UserLocal> listPlayers}) {
  Map mapAdd = {
    'nombre': Provider.of<UserData>(context, listen: false).user.displayName,
    'uid': Provider.of<UserData>(context, listen: false).user.id,
    'numReserved': Provider.of<ReservationData>(context, listen: false)
        .reservationMade
        .numJugadores,
  };
  List<Map> listReturn = [];
  for (Map jugador in listToChange) {
    listReturn.add(jugador);
  }
  listReturn.add(mapAdd);
  for (UserLocal userAdd in listPlayers) {
    listReturn.add({'nombre': userAdd.displayName, 'uid': userAdd.id});
  }
  print({'listReturn': listReturn});
  return listReturn;
}

List<String> changeGuests(
    {BuildContext context, List listGuests, List<String> guestsAdded}) {
  List<String> listReturn = [];
  for (dynamic guest in listGuests) {
    listReturn.add(guest);
  }
  for (String guest in guestsAdded) {
    listReturn.add(guest);
  }
  return listReturn;
}

List<Map> playersTeeTime({BuildContext context}) {
  List<Map> listReturn = [];
  if (Provider.of<ReservationData>(context, listen: false).teamPlayers.length >
      0) {
    for (UserLocal userLocal
        in Provider.of<ReservationData>(context, listen: false).teamPlayers) {
      Map mapAdd = {'nombre': userLocal.displayName, 'uid': userLocal.id};
      listReturn.add(mapAdd);
    }
  }
  return listReturn;
}

Future<String> uploadQr(
    {@required File imageFile,
    @required String userUid,
    @required String date}) async {
  String downloadUrl;
  firebase_storage.Reference ref =
      storageRef.child(userUid).child('/$date.jpg');
  firebase_storage.UploadTask uploadTask = ref.putFile(
    imageFile,
  );
  await uploadTask.whenComplete(() async {
    try {
      downloadUrl = await ref.getDownloadURL();
    } catch (err) {
      print(err);
    }
  });

  print({
    'downloadUrl': downloadUrl,
  });
  return downloadUrl;
  //firebase_storage.TaskSnapshot storageSnap = uploadTask.snapshot;
  //storageRef.child(userUid).child('/$date.jpg').getDownloadURL();
  //String downloadUrl = await storageSnap.ref.getDownloadURL();
  //return downloadUrl;
}

Future<File> toQrImageData(String text) async {
  try {
    final image = await QrPainter(
      data: text,
      version: QrVersions.auto,
      gapless: false,
    ).toImage(300);
    final a = await image.toByteData(format: ImageByteFormat.png);
    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/image.jpg').create();
    file.writeAsBytesSync(
      a.buffer.asUint8List(),
    );
    return file;
  } catch (e) {
    throw e;
  }
}

Future<bool> uploadPhotoStorage({
  BuildContext context,
  File imageFile,
}) async {
  String downloadPhotoUrl;

  if (imageFile != null) {
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Random random = new Random();
    int randomNumber = random.nextInt(1001);
    imageFileName = '$imageFileName-$randomNumber';

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(Provider.of<UserData>(context, listen: false).user.id)
        .child(imageFileName);
    firebase_storage.UploadTask storageUploadTask =
        storageReference.putFile(imageFile);

    await storageUploadTask.whenComplete(() async {
      try {
        downloadPhotoUrl = await storageReference.getDownloadURL();
      } catch (err) {
        print(err);
      }
    });

    if (downloadPhotoUrl != null) {
      await Provider.of<UserData>(context, listen: false).changePhoto(
        newPhoto: downloadPhotoUrl,
      );
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

String getTimeSlot({BuildContext context, String timeSlot}) {
  if (timeSlot == null) {
    return 'No tiene hora';
  } else {
    TimeSlot timeSlotFound = Provider.of<TimeSlotData>(context, listen: false)
        .times
        .firstWhere((element) => element.uid == timeSlot, orElse: () => null);
    if (timeSlotFound == null) {
      return 'No tiene hora';
    } else {
      int hour = timeSlotFound.hour;
      int minute = timeSlotFound.minute;

      String returnString;
      if (minute == 0) {
        returnString = "$hour:00";
      } else {
        returnString = "$hour:$minute";
      }

      if (hour > 11) {
        returnString = returnString + " pm";
      } else {
        returnString = returnString + " am";
      }

      return returnString;
    }
  }
}

bool allowAddGuests(
    {ReservationMade reservationDB, ReservationMade reservationLocal}) {
  if (reservationDB.guests.length > 1 ||
      reservationDB.guests.length + reservationLocal.guests.length > 2) {
    print('allow is false');
    return false;
  } else {
    return true;
  }
}
