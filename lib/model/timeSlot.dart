import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot {
  final String uid;
  final int hour;
  final int minute;
  final int minutesTotal;
  final String salida;

  TimeSlot({
    this.uid,
    this.hour,
    this.minute,
    this.minutesTotal,
    this.salida,
  });

  factory TimeSlot.fromDocument({DocumentSnapshot doc}) {
    return TimeSlot(
      uid: doc.id != null ? doc.id : null,
      hour: (doc.data() as Map)['hour'] != null
          ? (doc.data() as Map)['hour']
          : null,
      minute: (doc.data() as Map)['minute'] != null
          ? (doc.data() as Map)['minute']
          : null,
      minutesTotal: (doc.data() as Map)['minutesTotal'] != null
          ? (doc.data() as Map)['minutesTotal']
          : null,
      salida: (doc.data() as Map)['salida'] != null
          ? (doc.data() as Map)['salida']
          : null,
    );
  }
}
