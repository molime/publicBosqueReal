import 'package:cloud_firestore/cloud_firestore.dart';

final teeTimeRef = FirebaseFirestore.instance.collection('teeTime');

class TeeTime {
  final String uid;
  String reservation;
  String user;
  final DateTime timeMade;
  final String timeSlot;
  List<Map> guests;
  final DateTime teeTimeDate;
  final String qrUrl;
  List<String> outsideGuests;

  TeeTime({
    this.uid,
    this.user,
    this.reservation,
    this.timeMade,
    this.guests,
    this.timeSlot,
    this.teeTimeDate,
    this.qrUrl,
    this.outsideGuests,
  });

  factory TeeTime.fromDocument({
    DocumentSnapshot doc,
  }) {
    TeeTime teeTime = TeeTime(
      uid: doc.id,
      user: (doc.data() as Map)['user'] != null
          ? (doc.data() as Map)['user']
          : null,
      reservation: (doc.data() as Map)['reservation'] != null
          ? (doc.data() as Map)['reservation']
          : null,
      timeMade: (doc.data() as Map)['timeMade'] != null
          ? (doc.data() as Map)['timeMade'].toDate()
          : null,
      guests: [],
      timeSlot: (doc.data() as Map)['timeSlot'] ?? null,
      teeTimeDate: (doc.data() as Map)['teeTimeDate'] != null
          ? (doc.data() as Map)['teeTimeDate'].toDate()
          : null,
      qrUrl: (doc.data() as Map)['qrUrl'] != null
          ? (doc.data() as Map)['qrUrl']
          : null,
      outsideGuests: [],
    );

    if ((doc.data() as Map)['guests'] != null) {
      for (dynamic doc in (doc.data() as Map)['guests']) {
        Map mapGuests = {
          'nombre': doc['nombre'],
          'uid': doc['uid'],
        };
        teeTime.guests.add(mapGuests);
      }
    }

    if ((doc.data() as Map)['outsideGuests'] != null) {
      for (dynamic guest in (doc.data() as Map)['outsideGuests']) {
        teeTime.outsideGuests.add(guest);
      }
    }

    return teeTime;
  }
}
