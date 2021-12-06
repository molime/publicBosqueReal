import 'package:bosque_real/model/teeTime.dart';
import 'package:bosque_real/screens/main/reservation/reservation_detail.dart';
import 'package:bosque_real/utilities/functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Container buildTeeTimeCard({BuildContext context, TeeTime teeTime}) {
  return Container(
    child: Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFFe2b13c),
            child: Icon(
              Icons.sports_golf,
              color: Colors.white,
            ),
          ),
          title: teeTime.teeTimeDate != null
              ? Text(
                  DateFormat('dd/MM/yyyy').format(
                    teeTime.teeTimeDate,
                  ),
                )
              : Text('No tiene fecha'),
          subtitle: Text(
            getTimeSlot(
              context: context,
              timeSlot: teeTime.timeSlot,
            ),
          ),
          trailing: FlatButton.icon(
            icon: Icon(
              Icons.info_outline,
              color: Color(0xFFe2b13c),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationDetail(
                    teeTime: teeTime,
                  ),
                ),
              );
            },
            label: Text(
              'Detalle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFe2b13c),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10.0,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
