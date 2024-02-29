import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/pages/dashboard.dart';
import 'package:users_app/pages/home_page.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Importa flutter_stripe

Future<void> main() async
{
    Stripe.publishableKey = 'pk_test_51Oc9WPHDirRzPkGPs7RVgxaLXz7ZEpmeULsvZQsk5xDhtFPST7ke5TDCH03H444ijUW5xFcIt5R6YUSLEctCxlzG00ASdfAHZx'; // Reemplaza con tu clave pública de Stripe

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

 
  options: DefaultFirebaseOptions.currentPlatform,
);

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.locationWhenInUse.request();
    }
  }
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FirebaseAuth.instance.currentUser == null ? LoginScreen() : Dashboard(),
    );
  }
}

