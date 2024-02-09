import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global_variables.dart';
import 'package:users_app/pages/add_flete.dart';
import 'package:users_app/pages/payment_methods.dart';
import 'package:users_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

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
                Navigator.push(context, MaterialPageRoute(builder: (c) => ProfilePage()));
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
        child: Container(
          color: const Color.fromARGB(49, 0, 0, 0),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.black, size: 40),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userSurname.length > 10 ? userName.substring(0, 10) + '...' : userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      userSurname.length > 10 ? userSurname.substring(0, 10) + '...' : userSurname,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: Colors.grey),
                title: Text(
                  "Métodos de Pago",
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => PaymentMethodsPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.grey),
                title: Text(
                  "Acerca de",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.grey),
                title: Text(
                  "Cerrar Sesión",
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => AddFlete()));
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            "Agregar Flete",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
