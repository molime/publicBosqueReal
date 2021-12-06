import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationMade {
  final String uid;
  DateTime dateTime;
  String timeSlot;
  int numJugadores;
  String salida;
  List<Map> jugadores;
  List<String> guests;

  ReservationMade({
    this.uid,
    this.dateTime,
    this.timeSlot,
    this.numJugadores,
    this.jugadores,
    this.guests,
    this.salida,
  });

  factory ReservationMade.fromDocument({
    DocumentSnapshot doc,
  }) {
    ReservationMade reservationMade = ReservationMade(
      uid: doc.id != null ? doc.id : null,
      dateTime: (doc.data() as Map)['dateTime'] != null
          ? (doc.data() as Map)['dateTime'].toDate()
          : null,
      timeSlot: (doc.data() as Map)['timeSlot'] != null
          ? (doc.data() as Map)['timeSlot']
          : null,
      numJugadores: (doc.data() as Map)['numJugadores'] != null
          ? (doc.data() as Map)['numJugadores']
          : null,
      salida: (doc.data() as Map)['salida'] != null
          ? (doc.data() as Map)['salida']
          : null,
      jugadores: [],
      guests: [],
    );

    if ((doc.data() as Map)['jugadores'] != null) {
      for (dynamic docJugadores in (doc.data() as Map)['jugadores']) {
        Map mapJugador = {
          'nombre': docJugadores['nombre'].toString(),
          'uid': docJugadores['uid'].toString(),
          'numReserved': docJugadores['numReserved'],
        };
        reservationMade.jugadores.add(
          mapJugador,
        );
      }
    }

    if ((doc.data() as Map)['guests'] != null) {
      for (dynamic doc in (doc.data() as Map)['guests']) {
        reservationMade.guests.add(
          doc.toString(),
        );
      }
    }

    /*if (doc.data()['invitados'] != null) {
      for (dynamic doc in doc.data()['invitados']) {
        reservationMade.invitados.add(doc.toString());
      }
    }*/

    return reservationMade;
  }

  factory ReservationMade.empty({
    DateTime dateTime,
    String timeSlot,
  }) {
    return ReservationMade(
      uid: null,
      dateTime: dateTime,
      timeSlot: timeSlot,
      numJugadores: 1,
      guests: [],
      jugadores: [],
    );
  }

  factory ReservationMade.fromQuery({
    QueryDocumentSnapshot doc,
  }) {
    ReservationMade reservationMade = ReservationMade(
      uid: doc.id != null ? doc.id : null,
      dateTime: (doc.data() as Map)['dateTime'] != null
          ? (doc.data() as Map)['dateTime'].toDate()
          : null,
      timeSlot: (doc.data() as Map)['timeSlot'] != null
          ? (doc.data() as Map)['timeSlot']
          : null,
      numJugadores: (doc.data() as Map)['numJugadores'] != null
          ? (doc.data() as Map)['numJugadores']
          : null,
      salida: (doc.data() as Map)['salida'] != null
          ? (doc.data() as Map)['salida']
          : null,
      jugadores: [],
      guests: [],
    );

    if ((doc.data() as Map)['jugadores'] != null) {
      for (dynamic docJugadores in (doc.data() as Map)['jugadores']) {
        Map mapJugador = {
          'nombre': docJugadores['nombre'].toString(),
          'uid': docJugadores['uid'].toString(),
          'numReserved': docJugadores['numReserved'],
        };
        reservationMade.jugadores.add(
          mapJugador,
        );
      }
    }

    if ((doc.data() as Map)['guests'] != null) {
      for (dynamic doc in (doc.data() as Map)['guests']) {
        reservationMade.guests.add(
          doc.toString(),
        );
      }
    }

    /*if (doc.data()['invitados'] != null) {
      for (dynamic doc in doc.data()['invitados']) {
        reservationMade.invitados.add(doc.toString());
      }
    }*/

    return reservationMade;
  }

  void addPeople({int numPeople}) {
    numJugadores = numPeople;
  }

  void resetReservation() {
    this.numJugadores = 1;
  }
}
