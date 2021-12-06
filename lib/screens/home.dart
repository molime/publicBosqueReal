import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/model/user.dart';
import 'package:bosque_real/screens/main/reservation.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:bosque_real/screens/main/teeTime_history.dart';
import 'package:bosque_real/screens/main/profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  GlobalKey _bottomNavigationKey = GlobalKey();

  int _pageIndex = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(
      initialPage: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: [
            TeeTimeHistoryScreen(),
            Reservation(),
            ProfileScreen(),
          ],
          onPageChanged: (index) {
            setState(() {
              _pageController.jumpToPage(index);
            });
          },
        ),
        bottomNavigationBar: CurvedNavigationBar(
          onTap: (index) {
            setState(() {
              _pageIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          color: Color(0xFFe2b13c),
          buttonBackgroundColor: Color(0xFFe2b13c),
          key: _bottomNavigationKey,
          index: _pageIndex,
          animationCurve: Curves.easeInOut,
          backgroundColor: Colors.white,
          items: [
            Icon(
              Icons.list,
            ),
            Icon(
              Icons.watch_later_outlined,
            ),
            Icon(
              Icons.person,
            ),
          ],
        ),
      ),
    );
  }

  StatefulWidget _returnScreen() {
    if (_pageIndex == 0) {
      return TeeTimeHistoryScreen();
    } else if (_pageIndex == 1) {
      return Reservation();
    } else {
      return ProfileScreen();
    }
  }
}
