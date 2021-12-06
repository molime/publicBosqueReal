import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/model/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Container buildResultCard({
  UserLocal userElement,
  BuildContext context,
  Function onSetSearch,
  int numPlayers,
}) {
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
          title: Text(
            userElement.displayName,
          ),
          trailing: TextButton.icon(
            icon: Icon(
              Icons.person_add,
              color: Color(0xFFe2b13c),
            ),
            onPressed:
                Provider.of<ReservationData>(context).teamPlayers.length <
                        numPlayers - 1
                    ? () {
                        int added =
                            Provider.of<ReservationData>(context, listen: false)
                                .teamPlayers
                                .length;
                        Provider.of<ReservationData>(context, listen: false)
                            .addPlayer(userLocal: userElement);
                        added++;
                        if (added == numPlayers - 1) {
                          onSetSearch();
                        }
                      }
                    : () {},
            label: Text(
              'Agregar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFe2b13c),
              ),
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.0,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    ),
  );
  /*GestureDetector(
    onTap: Provider.of<ReservationData>(context).teamPlayers.length <
            numPlayers - 1
        ? () {
            int added = Provider.of<ReservationData>(context, listen: false)
                .teamPlayers
                .length;
            Provider.of<ReservationData>(context, listen: false)
                .addPlayer(userLocal: userElement);
            added++;
            if (added == numPlayers - 1) {
              onSetSearch();
            }
          }
        : () {},
    child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 2.0,
        child: Container(
            child: Center(
                child: Text(
          userElement.displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          ),
        )))),
  );*/
}

Padding playerAdded(
    {@required BuildContext context, @required UserLocal userLocal}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 20.0,
      vertical: 5.0,
    ),
    child: Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFe2b13c),
          child: Icon(
            Icons.person_outline,
            color: Colors.white,
          ),
        ),
        title: Text(
          userLocal.displayName,
        ),
        trailing: GestureDetector(
          onTap: () {
            Provider.of<ReservationData>(context, listen: false)
                .deletePlayer(userLocal: userLocal);
          },
          child: Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.remove_circle,
              ),
            ),
            label: Text(
              'Quitar',
            ),
          ),
        ),
      ),
    ),
  );
}
