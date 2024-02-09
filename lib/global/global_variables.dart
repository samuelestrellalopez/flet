import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

String userEmail = "";
String userName = "";
String userSurname = "";
String googleMapKey = "AIzaSyDPeaD3DFUBMR7RzovK3-jpMKsIcYG8Pt0";
String googlePlaceKey = "AIzaSyCRBQEpfhXKAmA7ZKA7CZfIZm6GZ4QVBtQ";
const CameraPosition googlePlexInitialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );



  const defaultPadding = 16.0;


Color primaryColor = const Color(0xff161922);
Color secondaryColor = Color.fromARGB(255, 248, 112, 33);
Color accentColor = Colors.grey;

double kSpacing = 20.00;

double kfontSize = 18.00;
double kLargefontSize = 25.00;

BorderRadius kBorderRadius = BorderRadius.circular(kSpacing);

EdgeInsets kPadding = EdgeInsets.all(kSpacing);

EdgeInsets kHPadding = EdgeInsets.symmetric(horizontal: kSpacing);
EdgeInsets kVPadding = EdgeInsets.symmetric(vertical: kSpacing);

getBtnStyle(context) => ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
    fixedSize: Size(MediaQuery.of(context).size.width, 47),
    primary: primaryColor,
    textStyle: const TextStyle(fontWeight: FontWeight.bold));

var btnTextStyle = TextStyle(fontSize: kfontSize);