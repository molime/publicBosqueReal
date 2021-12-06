import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/data/timeSlot_data.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/reservation.dart';
import 'package:bosque_real/model/timeSlot.dart';
import 'package:bosque_real/utilities/functions.dart';
import 'package:flutter/material.dart';

import 'package:bosque_real/utilities/constants.dart';
import 'package:provider/provider.dart';

class ShowTime extends StatefulWidget {
  //bool isActive;

  final String time;

  final Function toDoOnPressed;

  final TimeSlot timeSlot;

  ReservationMade reservationMade;

  ShowTime({
    @required this.time,
    @required this.timeSlot,
    this.reservationMade,
    //this.isActive = false,
    this.toDoOnPressed,
  });

  @override
  _ShowTimeState createState() => _ShowTimeState();
}

class _ShowTimeState extends State<ShowTime> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: lugaresQuedan(reservationMade: widget.reservationMade) > 0
          ? () {
              print('quedan lugares');
              if (Provider.of<TimeSlotData>(context, listen: false)
                  .isTimeSlot(timeSlot: widget.timeSlot)) {
                print('isTimeSlot');
                Provider.of<TimeSlotData>(context, listen: false)
                    .deleteTimeSlot();
                Provider.of<ReservationData>(context, listen: false)
                    .deleteReservation();
                Provider.of<ReservationData>(context, listen: false)
                    .setQuedan(newQuedan: 5);
              } else {
                //print('isnt time slot');
                /*print({
                  'timeSlot': widget.timeSlot != null,
                  'timeSlot.uid': widget.timeSlot.uid != null,
                });*/
                Provider.of<TimeSlotData>(context, listen: false)
                    .setTimeSlot(timeSlot: widget.timeSlot);
                Provider.of<ReservationData>(context, listen: false)
                    .setReservation(
                  reservationMade: widget.reservationMade,
                  timeSlot: widget.timeSlot.uid,
                );
                print({
                  'lugaresQuedan': lugaresQuedan(
                    reservationMade: widget.reservationMade,
                  )
                });
                Provider.of<ReservationData>(context, listen: false).setQuedan(
                  newQuedan: lugaresQuedan(
                    reservationMade: widget.reservationMade,
                  ),
                );
              }
              /*setState(() {
          widget.isActive = !widget.isActive;
        });*/
            }
          : () {
              //print('no quedan lugares');
            },
      child: Container(
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        decoration: BoxDecoration(
            border: Border.all(
                color: Provider.of<TimeSlotData>(context)
                        .isTimeSlot(timeSlot: widget.timeSlot)
                    ? kPimaryColor
                    : Colors.grey),
            borderRadius: BorderRadius.circular(15.0)),
        child: Column(
          children: <Widget>[
            Text(
              widget.time,
              style: TextStyle(
                  color: Provider.of<TimeSlotData>(context)
                          .isTimeSlot(timeSlot: widget.timeSlot)
                      ? kPimaryColor
                      : Colors.grey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
                'Quedan: ${lugaresQuedan(
                  reservationMade: widget.reservationMade,
                )}',
                style: TextStyle(color: Colors.grey, fontSize: 18.0))
          ],
        ),
      ),
    );
  }
}
