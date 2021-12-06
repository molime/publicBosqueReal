import 'package:bosque_real/config/auth.dart';
import 'package:bosque_real/data/reservation_data.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/user.dart';
import 'package:bosque_real/utilities/search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bosque_real/widgets/reusable_components.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final Function onSearchDone;
  final Function onBackPressed;

  SearchScreen({
    Key key,
    @required this.onBackPressed,
    @required this.onSearchDone,
  }) : super(
          key: key,
        );

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool searchingPlayers = true;
  String queryString;
  List<UserLocal> tempSearchStore = [];
  var queryResult = [];
  TextEditingController guestName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    guestName.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return searchingPlayers
        ? Scaffold(
            appBar: new AppBar(
              backgroundColor: Color(0xFFe2b13c),
              title: Text('Buscar'),
              leading: Container(),
            ),
            body: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SearchBar(
                    hint: 'Busca por nombre',
                    toDoPressed: null,
                    toDoChanged: (value) {
                      setState(() {
                        queryString = value;
                      });
                      initiateSearch(searchValue: queryString);
                    },
                    onBack: widget.onBackPressed,
                  ),
                ),
                if (Provider.of<ReservationData>(context).allowAddGuests()) ...[
                  SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            searchingPlayers = false;
                          });
                        },
                        child: Text(
                          "Agregar a un invitado (no socio)",
                          style: TextStyle(
                            color: Color(0xFFe2b13c),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: 10.0,
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: tempSearchStore.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildResultCard(
                      numPlayers: Provider.of<ReservationData>(context)
                          .reservationMade
                          .numJugadores,
                      userElement: tempSearchStore[index],
                      context: context,
                      onSetSearch: () {
                        widget.onSearchDone();
                      },
                    );
                  },
                ),
                /*GridView.count(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  primary: false,
                  shrinkWrap: true,
                  children: tempSearchStore.map((element) {
                    return buildResultCard(
                      numPlayers: Provider.of<ReservationData>(context)
                          .reservationMade
                          .numJugadores,
                      userElement: element,
                      context: context,
                      onSetSearch: () {
                        widget.onSearchDone();
                      },
                    );
                  }).toList(),
                ),*/
              ],
            ),
          )
        : Scaffold(
            appBar: new AppBar(
              backgroundColor: Color(0xFFe2b13c),
              title: Text('Escribir'),
              leading: Container(),
            ),
            body: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    width: MediaQuery.of(context).size.width * .70,
                    height: 60.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: .5),
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: guestName,
                            style: TextStyle(fontSize: 22, color: Colors.black),
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Escribe el nombre de tu invitado",
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon: IconButton(
                                color: Colors.black,
                                icon: Icon(Icons.arrow_back),
                                iconSize: 20.0,
                                onPressed: widget.onBackPressed,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.person_add,
                            size: 28.0,
                            color: guestName.text.length > 0
                                ? Color(0xFFe2b13c)
                                : Colors.grey,
                          ),
                          onPressed: guestName.text.length > 0
                              ? () {
                                  print('guest name valid');
                                  if (Provider.of<ReservationData>(context,
                                          listen: false)
                                      .allowAddGuests()) {
                                    print('allowed to add guests');
                                    print({'guestName': guestName.text});
                                    Provider.of<ReservationData>(context,
                                            listen: false)
                                        .addGuest(guest: guestName.text);
                                    setState(() {
                                      print('clearing guestName');
                                      guestName.clear();
                                    });
                                    Fluttertoast.showToast(
                                      msg:
                                          'Se ha agregado a tu invitado con éxito.',
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Ya se llegó al límite de invitados para esta salida",
                                    );
                                  }
                                }
                              : () {
                                  print('guest name invalid');
                                  print({
                                    'guestName': guestName.text,
                                    'guestName.text.length':
                                        guestName.text.length
                                  });
                                  Fluttertoast.showToast(
                                    msg:
                                        "Por favor escribe el nombre de tu invitado",
                                  );
                                },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount:
                      Provider.of<ReservationData>(context).guests.length,
                  itemBuilder: (BuildContext context, int index) {
                    String guest =
                        Provider.of<ReservationData>(context).guests[index];
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
                              guest,
                            ),
                            trailing: TextButton.icon(
                              icon: Icon(
                                Icons.person_remove,
                                color: Color(0xFFe2b13c),
                              ),
                              onPressed: () {
                                Provider.of<ReservationData>(context,
                                        listen: false)
                                    .deleteGuest(guest: guest);
                              },
                              label: Text(
                                'Quitar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFe2b13c),
                                ),
                              ),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.resolveWith<
                                    OutlinedBorder>((_) {
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
                  },
                ),
              ],
            ),
          );
  }

  void initiateSearch({String searchValue}) async {
    String newSearch = searchValue.trim().toLowerCase();

    if (newSearch.length == 0) {
      setState(() {
        queryResult = [];
        tempSearchStore = [];
      });
    } else {
      setState(() {
        tempSearchStore = [];
      });

      QuerySnapshot results = await FirebaseFirestore.instance
          .collection('users')
          .where('searchTerms', arrayContains: newSearch)
          .where("id",
              isNotEqualTo:
                  Provider.of<UserData>(context, listen: false).user.id)
          .get();

      for (DocumentSnapshot documentSnapshot in results.docs) {
        setState(() {
          tempSearchStore.add(
            UserLocal.fromDocument(documentSnapshot),
          );
        });
      }
    }
  }
}

Scaffold searchScreen({
  @required BuildContext context,
  @required List<UserLocal> tempSearchStore,
  @required Function searchFunction,
  @required int numPlayers,
  Function onSearchDone,
  Function onBackPressed,
}) {
  return Scaffold(
    appBar: new AppBar(
      backgroundColor: Color(0xFFe2b13c),
      title: Text('Buscar'),
      leading: Container(),
    ),
    body: ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SearchBar(
            hint: 'Busca por nombre',
            toDoPressed: null,
            toDoChanged: (value) {
              searchFunction(
                value,
              );
            },
            onBack: onBackPressed,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        GridView.count(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
          ),
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          primary: false,
          shrinkWrap: true,
          children: tempSearchStore.map((element) {
            return buildResultCard(
              numPlayers: numPlayers,
              userElement: element,
              context: context,
              onSetSearch: () {
                onSearchDone();
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}
