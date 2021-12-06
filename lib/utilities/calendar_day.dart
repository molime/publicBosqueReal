import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/data/timeSlot_data.dart';
import 'package:bosque_real/utilities/functions.dart';
import 'package:flutter/material.dart';

import 'package:bosque_real/utilities/constants.dart';
import 'package:provider/provider.dart';

class CalendarDay extends StatelessWidget {
  final DateTime dateTime;
  CalendarDay({
    @required this.dateTime,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Provider.of<ReservationData>(context).isSelectedDate(dateTime: dateTime) ? () {} : () {
        Provider.of<ReservationData>(context, listen: false).setSelectedDate(dateTime: dateTime);
        Provider.of<TimeSlotData>(context, listen: false).deleteTimeSlot();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          width: 50.0,
          height: 65.0,
          decoration: BoxDecoration(
              color: Provider.of<ReservationData>(context).isSelectedDate(dateTime: dateTime) ? kPimaryColor : null,
              borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('${dateTime.day}',
                  style: TextStyle(
                      color: Provider.of<ReservationData>(context).isSelectedDate(dateTime: dateTime) ? Colors.black : Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold)),
              Text(
                weekday(dateTime.weekday).toUpperCase(),
                style: TextStyle(
                  color: Provider.of<ReservationData>(context).isSelectedDate(dateTime: dateTime) ? Colors.black : Colors.white70,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
