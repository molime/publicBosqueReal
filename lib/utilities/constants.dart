import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFFe2b13c),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

Color scaffoldBgColor = Color(0xFFF4F4F4);
Color primaryColor = Color(0xFFF2647C);
Color darkPrimaryColor = Color(0xFFCA445D);
Color greyColor = Colors.grey;
Color whiteColor = Colors.white;
Color blackColor = Colors.black;
Color lightGreyColor = Colors.grey.withOpacity(0.3);

double fixPadding = 10.0;

SizedBox heightSpace = SizedBox(height: 10.0);
SizedBox widthSpace = SizedBox(width: 10.0);

TextStyle bottomBarItemStyle = TextStyle(
  color: greyColor,
  fontSize: 12.0,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle bigHeadingStyle = TextStyle(
  fontSize: 22.0,
  color: blackColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
);

TextStyle headingStyle = TextStyle(
  fontSize: 18.0,
  color: blackColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle greyHeadingStyle = TextStyle(
  fontSize: 16.0,
  color: greyColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle blueTextStyle = TextStyle(
  fontSize: 18.0,
  color: Colors.blue,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

TextStyle whiteHeadingStyle = TextStyle(
  fontSize: 22.0,
  color: whiteColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle whiteSubHeadingStyle = TextStyle(
  fontSize: 14.0,
  color: whiteColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.normal,
);

TextStyle wbuttonWhiteTextStyle = TextStyle(
  fontSize: 16.0,
  color: whiteColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle buttonBlackTextStyle = TextStyle(
  fontSize: 16.0,
  color: blackColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle moreStyle = TextStyle(
  fontSize: 14.0,
  color: primaryColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle priceStyle = TextStyle(
  fontSize: 18.0,
  color: primaryColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.bold,
);

TextStyle lightGreyStyle = TextStyle(
  fontSize: 15.0,
  color: Colors.grey.withOpacity(0.6),
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

// List Item Style Start
TextStyle listItemTitleStyle = TextStyle(
  fontSize: 15.0,
  color: blackColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);
TextStyle listItemSubTitleStyle = TextStyle(
  fontSize: 14.0,
  color: greyColor,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.normal,
);

// List Item Style End

// AppBar Style Start
TextStyle appbarHeadingStyle = TextStyle(
  color: darkPrimaryColor,
  fontSize: 14.0,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);
TextStyle appbarSubHeadingStyle = TextStyle(
  color: whiteColor,
  fontSize: 13.0,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);
// AppBar Style End

// Search text style start
TextStyle searchTextStyle = TextStyle(
  color: whiteColor.withOpacity(0.6),
  fontSize: 16.0,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);
// Search text style end

// Search History text style start

// Search History text style End


//FROM MOVIE SEAT App
const kPimaryColor = Color(0xFFe2b13c);

const kActionColor = Color(0xffF00000);

const kBackgroundColor = Color(0xffFFFFFF);
const kMovieNameStyle =
TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white , );
final kMainTextStyle = GoogleFonts.barlow(
    textStyle: TextStyle(
        color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold));
final kSmallMainTextStyle = kMainTextStyle.copyWith(fontSize: 16.0);

final kPromaryColorTextStyle =
TextStyle(color: kPimaryColor, fontSize: 18.0, fontWeight: FontWeight.bold);

final BoxDecoration kRoundedFadedBorder = BoxDecoration(
    border: Border.all(color: Colors.black38, width: .5),
    borderRadius: BorderRadius.circular(15.0));

final ThemeData theme =
ThemeData.dark().copyWith(textTheme: GoogleFonts.barlowTextTheme());