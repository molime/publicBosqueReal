import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/data/timeSlot_data.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/reservation.dart';
import 'package:bosque_real/model/timeSlot.dart';
import 'package:bosque_real/utilities/functions.dart';
import 'package:bosque_real/widgets/reusable_components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:bosque_real/model/user.dart';

import 'package:bosque_real/utilities/constants.dart';
import 'package:bosque_real/utilities/calendar_day.dart';
import 'package:bosque_real/utilities/show_time.dart';
import 'package:bosque_real/utilities/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_picker/flutter_picker.dart';

final reservationRef = FirebaseFirestore.instance.collection('reservations');

SafeArea mainReservationScreen({
  @required Future<Map> getTime,
  @required Function selectPlayers,
  @required Function warningSelect,
  @required GlobalKey<ScaffoldState> scaffoldKey,
  //@required int people,
  @required Function doPressed,
  @required Function onRefreshIndicator,
  @required BuildContext context,
  @required RefreshController refreshController,
  @required bool showSpinner,
  @required Function changeSpinner,
}) {
  return SafeArea(
    child: Scaffold(
      key: scaffoldKey,
      backgroundColor: kBackgroundColor,
      body: Provider.of<ReservationData>(context).showLoading(context)
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 15.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitRing(
                      color: Colors.black38,
                      size: 50.0,
                    ),
                  ],
                ),
              ),
            )
          : SmartRefresher(
              controller: refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: () async {
                await Provider.of<ReservationData>(context, listen: false)
                    .futureDates();
                refreshController.refreshCompleted();
              },
              onLoading: () async {
                await Provider.of<ReservationData>(context, listen: false)
                    .futureDates();
                refreshController.loadComplete();
              },
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body;

                  if (mode == LoadStatus.idle) {
                    body = Text(
                      'Jala para refrescar',
                    );
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text(
                      'Falló la carga, vuelve a intentarlo',
                    );
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text(
                      'Libera para cargar más',
                    );
                  } else {
                    body = Text(
                      'No hay más datos por cargar',
                    );
                  }

                  return Container(
                    height: 55.0,
                    child: Center(
                      child: body,
                    ),
                  );
                },
              ),
              child: ModalProgressHUD(
                inAsyncCall: showSpinner,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: ListView(
                        shrinkWrap: true,
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, left: 15.0),
                            child: Row(
                              children: <Widget>[
                                Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .75,
                                    child: Text(
                                      DateFormat('dd/MM/yyyy hh:mm').format(
                                          Provider.of<ReservationData>(context)
                                              .currentDate),
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                width: MediaQuery.of(context).size.width * .45,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(25.0),
                                    topLeft: Radius.circular(25.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: <Widget>[
                                        CalendarDay(
                                          dateTime:
                                              Provider.of<ReservationData>(
                                                      context)
                                                  .dateTimesFuture[0],
                                        ),
                                        CalendarDay(
                                          dateTime:
                                              Provider.of<ReservationData>(
                                                      context)
                                                  .dateTimesFuture[1],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<List<ReservationMade>>(
                              stream: streamReservation(
                                dateTime: Provider.of<ReservationData>(context)
                                    .dateTimeSelected,
                              ),
                              builder: (context, snapshotTimes) {
                                if (!snapshotTimes.hasData) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 15.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SpinKitRing(
                                            color: Colors.black38,
                                            size: 50.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: timeSlots(
                                              times: Provider.of<TimeSlotData>(
                                                      context)
                                                  .times,
                                              dateSelected:
                                                  Provider.of<ReservationData>(
                                                          context)
                                                      .dateTimeSelected,
                                              dateNow:
                                                  Provider.of<ReservationData>(
                                                          context)
                                                      .currentDate,
                                            ).length >
                                            0
                                        ? Row(
                                            children: List<ShowTime>.generate(
                                                timeSlots(
                                                  times:
                                                      Provider.of<TimeSlotData>(
                                                              context)
                                                          .times,
                                                  dateSelected: Provider.of<
                                                              ReservationData>(
                                                          context)
                                                      .dateTimeSelected,
                                                  dateNow: Provider.of<
                                                              ReservationData>(
                                                          context)
                                                      .currentDate,
                                                ).length, (int index) {
                                              return ShowTime(
                                                time: getHourString(
                                                  hour: timeSlots(
                                                    times: Provider.of<
                                                                TimeSlotData>(
                                                            context)
                                                        .times,
                                                    dateSelected: Provider.of<
                                                                ReservationData>(
                                                            context)
                                                        .dateTimeSelected,
                                                    dateNow: Provider.of<
                                                                ReservationData>(
                                                            context)
                                                        .currentDate,
                                                  )[index]
                                                      .hour,
                                                  minute: timeSlots(
                                                    times: Provider.of<
                                                                TimeSlotData>(
                                                            context)
                                                        .times,
                                                    dateSelected: Provider.of<
                                                                ReservationData>(
                                                            context)
                                                        .dateTimeSelected,
                                                    dateNow: Provider.of<
                                                                ReservationData>(
                                                            context)
                                                        .currentDate,
                                                  )[index]
                                                      .minute,
                                                ),
                                                timeSlot: timeSlots(
                                                  times:
                                                      Provider.of<TimeSlotData>(
                                                              context)
                                                          .times,
                                                  dateSelected: Provider.of<
                                                              ReservationData>(
                                                          context)
                                                      .dateTimeSelected,
                                                  dateNow: Provider.of<
                                                              ReservationData>(
                                                          context)
                                                      .currentDate,
                                                )[index],
                                                reservationMade:
                                                    findReservation(
                                                  reservations:
                                                      snapshotTimes.data,
                                                  dateSelected: Provider.of<
                                                              ReservationData>(
                                                          context)
                                                      .dateTimeSelected,
                                                  timeCompare:
                                                      Provider.of<TimeSlotData>(
                                                              context)
                                                          .times[index]
                                                          .uid,
                                                ),
                                              );
                                            }),
                                          )
                                        : Container(),
                                  );
                                }
                              }),
                          if (useStream(
                            timeSlot:
                                Provider.of<TimeSlotData>(context).timeSlot,
                            dateTime: Provider.of<ReservationData>(context)
                                .dateTimeSelected,
                          )) ...[
                            StreamBuilder<ReservationMade>(
                                stream: reservationToStream(
                                  reservationUid: Provider.of<ReservationData>(
                                                  context)
                                              .reservationMade
                                              .uid !=
                                          null
                                      ? Provider.of<ReservationData>(context)
                                          .reservationMade
                                          .uid
                                      : null,
                                  dateTime:
                                      Provider.of<ReservationData>(context)
                                          .dateTimeSelected,
                                  timeSlotUid:
                                      Provider.of<TimeSlotData>(context)
                                          .timeSlot
                                          .uid,
                                ),
                                builder: (context, snapshotReservation) {
                                  if (!snapshotReservation.hasData) {
                                    return GestureDetector(
                                      onTap: () {
                                        selectPlayers();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.people_alt_outlined,
                                              color: kPimaryColor,
                                              size: 25.0,
                                            ),
                                            SizedBox(width: 20.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Tamaño del grupo',
                                                  style: GoogleFonts.barlow(
                                                    textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                    Provider.of<ReservationData>(
                                                                    context)
                                                                .reservationMade !=
                                                            null
                                                        ? 'Personas: ${Provider.of<ReservationData>(context).reservationMade.numJugadores}'
                                                        : 'Personas: 1',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 18.0)),
                                                SizedBox(height: 10.0),
                                              ],
                                            ),
                                            SizedBox(width: 20.0),
                                            Icon(
                                              Icons.keyboard_arrow_right,
                                              size: 30.0,
                                              color: Colors.white38,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    print({
                                      'data.numJugadores':
                                          snapshotReservation.data.numJugadores,
                                    });
                                    return GestureDetector(
                                      onTap: () {
                                        selectPlayers();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.people_alt_outlined,
                                              color: kPimaryColor,
                                              size: 25.0,
                                            ),
                                            SizedBox(width: 20.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Tamaño del grupo',
                                                  style: GoogleFonts.barlow(
                                                    textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                    Provider.of<ReservationData>(
                                                                    context)
                                                                .reservationMade !=
                                                            null
                                                        ? 'Personas: ${Provider.of<ReservationData>(context).reservationMade.numJugadores}'
                                                        : 'Personas: 1',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 18.0)),
                                                SizedBox(height: 10.0),
                                              ],
                                            ),
                                            SizedBox(width: 20.0),
                                            Icon(
                                              Icons.keyboard_arrow_right,
                                              size: 30.0,
                                              color: Colors.white38,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                }),
                          ],
                          if (!useStream(
                            timeSlot:
                                Provider.of<TimeSlotData>(context).timeSlot,
                            dateTime: Provider.of<ReservationData>(context)
                                .dateTimeSelected,
                          )) ...[
                            GestureDetector(
                              onTap: warningSelect,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.people_alt_outlined,
                                      color: kPimaryColor,
                                      size: 25.0,
                                    ),
                                    SizedBox(width: 20.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Tamaño del grupo',
                                          style: GoogleFonts.barlow(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                            Provider.of<ReservationData>(
                                                            context)
                                                        .reservationMade !=
                                                    null
                                                ? 'Personas: ${Provider.of<ReservationData>(context).reservationMade.numJugadores}'
                                                : 'Personas: 1',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 18.0)),
                                        SizedBox(height: 10.0),
                                      ],
                                    ),
                                    SizedBox(width: 20.0),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 30.0,
                                      color: Colors.white38,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '¿Con quiénes vas a jugar? (opcional)',
                                  style: GoogleFonts.barlow(
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                SearchBar(
                                  hint: 'Busca jugador',
                                  toDoPressed: doPressed,
                                  toDoChanged: () => null,
                                  onBack: null,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                if (Provider.of<ReservationData>(context)
                                        .teamPlayers
                                        .length >
                                    0) ...[
                                  ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount:
                                        Provider.of<ReservationData>(context)
                                            .teamPlayers
                                            .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      UserLocal userIter =
                                          Provider.of<ReservationData>(context)
                                              .teamPlayers[index];
                                      return Container(
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Color(0xFFe2b13c),
                                                child: Icon(
                                                  Icons.sports_golf,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              title: Text(
                                                userIter.displayName,
                                              ),
                                              trailing: TextButton.icon(
                                                icon: Icon(
                                                  Icons.person_remove,
                                                  color: Color(0xFFe2b13c),
                                                ),
                                                onPressed: () {
                                                  Provider.of<ReservationData>(
                                                          context,
                                                          listen: false)
                                                      .deletePlayer(
                                                          userLocal: userIter);
                                                },
                                                label: Text(
                                                  'Quitar',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFe2b13c),
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .resolveWith<
                                                          OutlinedBorder>((_) {
                                                    return RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
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
                                    },
                                  ),
                                ],
                                if (Provider.of<ReservationData>(context)
                                        .guests
                                        .length >
                                    0) ...[
                                  ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount:
                                        Provider.of<ReservationData>(context)
                                            .guests
                                            .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String guest =
                                          Provider.of<ReservationData>(context)
                                              .guests[index];
                                      return Container(
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Color(0xFFe2b13c),
                                                child: Icon(
                                                  Icons.sports_golf,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              title: Text(
                                                guest,
                                              ),
                                              trailing: TextButton.icon(
                                                icon: Icon(
                                                  Icons.person_remove,
                                                  color: Color(0xFFe2b13c),
                                                ),
                                                onPressed: () {
                                                  Provider.of<ReservationData>(
                                                          context,
                                                          listen: false)
                                                      .deleteGuest(
                                                          guest: guest);
                                                },
                                                label: Text(
                                                  'Quitar',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFe2b13c),
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .resolveWith<
                                                          OutlinedBorder>((_) {
                                                    return RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
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
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          /*ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: Provider.of<ReservationData>(context)
                                .teamPlayers
                                .length,
                            itemBuilder: (BuildContext context, int index) {
                              return playerAdded(
                                context: context,
                                userLocal: Provider.of<ReservationData>(context)
                                    .teamPlayers[index],
                              );
                            },
                          ),*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.0,
                      ),
                      child: Provider.of<ReservationData>(context)
                              .allowReservationCreation()
                          ? RaisedButton(
                              onPressed: Provider.of<UserData>(context)
                                      .user
                                      .validated
                                  ? () async {
                                      changeSpinner(true);
                                      bool success = await createReservation(
                                        context: context,
                                        reservationRef: reservationRef,
                                        guests: Provider.of<ReservationData>(context, listen: false).guests.toList(),
                                        players: Provider.of<ReservationData>(context, listen: false).teamPlayers.toList(),
                                        host: Provider.of<UserData>(context, listen: false).user
                                      );
                                      Provider.of<TimeSlotData>(context,
                                              listen: false)
                                          .deleteTimeSlot();
                                      Provider.of<ReservationData>(context,
                                              listen: false)
                                          .clearPlayers();
                                      Provider.of<ReservationData>(context,
                                              listen: false)
                                          .clearGuests();
                                      Provider.of<ReservationData>(context,
                                              listen: false)
                                          .deleteReservation();
                                      changeSpinner(false);
                                      if (success) {
                                        SnackBar snackbar = SnackBar(
                                          content: Text(
                                            '¡Se realizó la reservación con éxito!',
                                          ),
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      } else {
                                        SnackBar snackbar = SnackBar(
                                          content: Text(
                                            'Ya no hay lugares suficientes en la hora seleccionada, lo sentimos',
                                          ),
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      }
                                    }
                                  : () async {
                                      changeSpinner(true);
                                      DocumentSnapshot doc = await usersRef
                                          .doc(Provider.of<UserData>(context,
                                                  listen: false)
                                              .user
                                              .id)
                                          .get();
                                      bool isValid =
                                          UserLocal.fromDocument(doc).validated;
                                      if (isValid) {
                                        bool success = await createReservation(
                                          context: context,
                                          reservationRef: reservationRef,
                                            guests: Provider.of<ReservationData>(context, listen: false).guests.toList(),
                                            players: Provider.of<ReservationData>(context, listen: false).teamPlayers.toList(),
                                            host: Provider.of<UserData>(context, listen: false).user
                                        );
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .makeValid();
                                        Provider.of<TimeSlotData>(context,
                                                listen: false)
                                            .deleteTimeSlot();
                                        Provider.of<ReservationData>(context,
                                                listen: false)
                                            .clearPlayers();
                                        Provider.of<ReservationData>(context,
                                                listen: false)
                                            .clearGuests();
                                        Provider.of<ReservationData>(context,
                                                listen: false)
                                            .deleteReservation();
                                        changeSpinner(false);
                                        if (success) {
                                          SnackBar snackbar = SnackBar(
                                            content: Text(
                                              '¡Se realizó la reservación con éxito!',
                                            ),
                                            duration: Duration(
                                              seconds: 3,
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);
                                        } else {
                                          SnackBar snackbar = SnackBar(
                                            content: Text(
                                              'Ya no hay lugares suficientes en la hora seleccionada, lo sentimos',
                                            ),
                                            duration: Duration(
                                              seconds: 3,
                                            ),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);
                                        }
                                      } else {
                                        changeSpinner(false);
                                        SnackBar snackbar = SnackBar(
                                          content: Text(
                                            'Tu membresía todavía no ha sido validada, lo sentimos',
                                          ),
                                          duration: Duration(
                                            seconds: 3,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      }
                                    },
                              child: Text(
                                'CONFIRMAR',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Color(0xFFe2b13c),
                                  ),
                                ),
                              ),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20.0,
                                ),
                                side: BorderSide(
                                  color: Color(0xFFe2b13c),
                                ),
                              ),
                            )
                          : RaisedButton(
                              onPressed: () {
                                Fluttertoast.showToast(
                                    msg:
                                        "Por favor especificar quienes forman parte de su grupo");
                              },
                              child: Text(
                                'CONFIRMAR',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20.0,
                                ),
                                side: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    ),
  );
}
