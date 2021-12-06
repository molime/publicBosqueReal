import 'package:bosque_real/data/teeTime_data.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/teeTime.dart';
import 'package:bosque_real/widgets/tee_time/teeTime_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TeeTimeHistoryScreen extends StatefulWidget {
  @override
  _TeeTimeHistoryScreenState createState() => _TeeTimeHistoryScreenState();
}

class _TeeTimeHistoryScreenState extends State<TeeTimeHistoryScreen> {
  DateTime _selectedDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTeeTimes();
  }

  Future<void> startTeeTimes() async {
    await Provider.of<TeeTimeData>(context, listen: false).initTeeTimes(
      userId: Provider.of<UserData>(context, listen: false).user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFe2b13c),
          leading: Container(),
          actions: [
            IconButton(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
              ),
              onPressed: _selectedDate == null
                  ? () async {
                      if (Provider.of<TeeTimeData>(context, listen: false)
                              .teeTimes
                              .length >
                          0) {
                        DateTime datePicked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            Duration(days: 30),
                          ),
                        );

                        setState(() {
                          _selectedDate = datePicked;
                        });

                        List<TeeTime> listTeeTime =
                            Provider.of<TeeTimeData>(context, listen: false)
                                .teeTimes
                                .where(
                                  (teeTime) =>
                                      DateTime(
                                        teeTime.teeTimeDate.year,
                                        teeTime.teeTimeDate.month,
                                        teeTime.teeTimeDate.day,
                                      ) ==
                                      DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month,
                                        _selectedDate.day,
                                      ),
                                )
                                .toList();

                        Provider.of<TeeTimeData>(context, listen: false)
                            .setTeeTimesDateSelected(teeTimesList: listTeeTime);
                      }
                    }
                  : () {
                      setState(() {
                        _selectedDate = null;
                      });
                      Provider.of<TeeTimeData>(context, listen: false)
                          .deleteListTeeTimesDate();
                    },
            ),
          ],
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            if (Provider.of<TeeTimeData>(context).teeTimes.length < 1) ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'No tienes reservaciones',
                        style: GoogleFonts.barlow(
                          textStyle: TextStyle(
                            color: Color(0xFFe2b13c),
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.sports_golf,
                        color: Color(0xFFe2b13c),
                      )
                    ],
                  ),
                ),
              ),
            ],
            if (Provider.of<TeeTimeData>(context).teeTimes.length >= 1) ...[
              if (_selectedDate == null) ...[
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount:
                        Provider.of<TeeTimeData>(context).teeTimes.length,
                    itemBuilder: (BuildContext context, int index) {
                      TeeTime teeTime =
                          Provider.of<TeeTimeData>(context).teeTimes[index];
                      return buildTeeTimeCard(
                        context: context,
                        teeTime: teeTime,
                      );
                    },
                  ),
                ),
              ],
              if (_selectedDate != null) ...[
                if (Provider.of<TeeTimeData>(context).teeTimesSelected.length <
                    1) ...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'No se encontraron reservaciones en esta fecha',
                            style: GoogleFonts.barlow(
                              textStyle: TextStyle(
                                color: Color(0xFFe2b13c),
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.sports_golf,
                            color: Color(0xFFe2b13c),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                if (Provider.of<TeeTimeData>(context).teeTimesSelected.length >=
                    1) ...[
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: Provider.of<TeeTimeData>(context)
                          .teeTimesSelected
                          .length,
                      itemBuilder: (BuildContext context, int index) {
                        TeeTime teeTime = Provider.of<TeeTimeData>(context)
                            .teeTimesSelected[index];
                        return buildTeeTimeCard(
                          context: context,
                          teeTime: teeTime,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ]
          ],
        ),
      ),
    );
  }
}
