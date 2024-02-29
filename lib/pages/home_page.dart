import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global_variables.dart';
import 'package:users_app/pages/add_flete.dart';
import 'package:users_app/pages/payment_methods.dart';
import 'package:users_app/pages/profile_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  late GoogleMapController _mapController;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  Set<Marker> _markers = {};
  List<String> paymentMethods = [];

  Future<User?> getCurrentUser() async {
    await Firebase.initializeApp();
    return FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _initLocation() async {
    var location = Location();
    try {
      var currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = currentLocation;
      });
      _updateMarker();
      _locationSubscription = location.onLocationChanged.listen((locationData) {
        setState(() {
          _currentLocation = locationData;
        });
        _updateMarker();
      });
    } catch (e) {
      print("Error obteniendo la ubicación: $e");
    }
  }

  void _updateMarker() {
    _markers.clear();
    if (_currentLocation != null) {
      _markers.add(Marker(
        markerId: MarkerId("currentLocation"),
        position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        infoWindow: InfoWindow(title: "Mi Ubicación"),
      ));
      _mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FleT",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => ProfilePage()));
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      key: sKey,
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                '${userName.length > 10 ? userName.substring(0, 10) + '...' : userName} ${userSurname.length > 10 ? userSurname.substring(0, 10) + '...' : userSurname}',
                style: TextStyle(fontSize: 12),
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser!.email ?? '', 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255)
                    .withOpacity(0.5),
                child: Icon(Icons.person, color: Colors.black, size: 30),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 254, 252, 249).withOpacity(0.5),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.credit_card,
                        color: Colors.grey, size: 20),
                    title:
                        Text("Métodos de Pago", style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => PaymentMethodsPage()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.grey, size: 20),
                    title: Text("Acerca de", style: TextStyle(color: Colors.grey)),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.grey, size: 20),
                    title:
                        Text("Cerrar Sesión", style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => LoginScreen()));
                    },
                  ),
                  for (String paymentMethod in paymentMethods)
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(paymentMethod),
                      onTap: () {
                        confirmDeletePaymentMethod(paymentMethod);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _loadMapStyle();
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 14.4746,
            ),
            zoomControlsEnabled: false,
            markers: _markers,
          ),
          Positioned(
            bottom: 30.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => AddFlete()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 255, 255, 255),
                  elevation: 0,
                  shadowColor: const Color.fromARGB(109, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 13.0, vertical: 9.0),
                ),
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                label: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pide tu flete aquí",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: Colors.black),
                ),
                SizedBox(height: 8.0),
                FloatingActionButton(
                  onPressed: () {
                    _mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMapStyle() async {
    try {
      String style = await rootBundle.loadString('assets/themes/night_style.json');
      _mapController.setMapStyle(style);
      print("Map style loaded successfully");
    } catch (e) {
      print("Error loading map style: $e");
    }
  }

  void confirmDeletePaymentMethod(String paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Eliminación"),
          content: Text("¿Deseas confirmar la eliminación de $paymentMethod?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                deletePaymentMethod(paymentMethod);
                Navigator.of(context).pop();
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void deletePaymentMethod(String paymentMethod) async {
    setState(() {
      paymentMethods.remove(paymentMethod);
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference databaseReference = FirebaseDatabase.instance.reference().child('PaymentMethods').child(userId);

      try {
        DataSnapshot snapshot = await databaseReference.once().then((event) => event.snapshot);
        Map<dynamic, dynamic>? methods = snapshot.value as Map<dynamic, dynamic>?;
        if (methods != null) {
          methods.forEach((key, value) {
            if (value['encryptedMethod'] == paymentMethod) {
              String? childKey = key as String?;
              if (childKey != null) {
                databaseReference.child(childKey).remove().then((_) {
                  print("Método de pago eliminado correctamente");
                }).catchError((error) {
                  print("Error al eliminar el método de pago: $error");
                });
              } else {
                print("La clave del hijo es nula");
              }
            }
          });
        }
      } catch (error) {
        print("Error al acceder a los métodos de pago: $error");
      }
    }
  }









}
